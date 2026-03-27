{
  description = "Personal cross-platform dotfiles flake";

  inputs = {
    # Base package set used by every target system.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # macOS system configuration framework.
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # User-level configuration framework shared by macOS and Linux.
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Overlay for a newer Neovim package in the shared package set.
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, ... }:
    let
      # Reuse helper functions from nixpkgs throughout the flake.
      lib = nixpkgs.lib;

      # Decide whether a host should be built with nix-darwin or standalone
      # Home Manager based on its target system string.
      isDarwin = host: lib.hasSuffix "darwin" host.system;

      # Fill in default paths so every host entry has the same shape, even when
      # `homeDirectory` or `flakeDirectory` are omitted in `hosts.nix`.
      # {
      #   system
      #   username
      #   homeDirectory
      #   flakeDirectory
      # }
      mkHost = host:
        let
          homeDirectory = host.homeDirectory or (
            if isDarwin host then
              "/Users/${host.username}"
            else
              "/home/${host.username}"
          );
        in
        host // {
          inherit homeDirectory;
          flakeDirectory = host.flakeDirectory or "${homeDirectory}/.dot";
        };

      # Load the host inventory and normalize each entry once up front.
      hosts = lib.mapAttrs (_: host: mkHost host) (import ./hosts.nix);

      # Import nixpkgs for one target system with the repo's shared policy.
      mkPkgs = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # Shared Home Manager module wiring reused by both standalone Home
      # Manager configs and the Home Manager module embedded in nix-darwin.
      mkHomeModule = host: {
        # Import the Home Manager module tree from `home/default.nix`.
        imports = [ ./home ];
        home = {
          inherit (host) username homeDirectory;
        };
      };

      # Build a standalone Home Manager configuration for non-Darwin hosts.
      mkHome = _: host: home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs host.system;
        extraSpecialArgs = {
          inherit inputs;
        };
        modules = [ (mkHomeModule host) ];
      };

      # Build a nix-darwin system for macOS hosts and attach the same Home
      # Manager module so user config stays defined in one place.
      mkDarwin = hostName: host: nix-darwin.lib.darwinSystem {
        system = host.system;

        # `specialArgs` is an escape hatch from the Nix module system
        # (defined in nixpkgs `lib/modules.nix` -> `lib.evalModules`).
        # It passes arbitrary values directly into every module's function
        # argument list before option evaluation begins.
        #
        # There is no predefined list of allowed keys: you invent the names
        # here and destructure them in the receiving module:
        #
        #   # darwin/default.nix
        #   { config, pkgs, hostName, flakeDirectory, username, ... }: { ... }
        #
        # Values passed here:
        #   self           - the flake's own output set
        #   hostName       - the attribute name from `darwinConfigurations`
        #   flakeDirectory - absolute path where the flake lives on disk
        #   username       - primary user account name
        #   homeDirectory  - absolute path to the user's home directory
        specialArgs = {
          inherit self hostName;
          inherit (host) flakeDirectory username homeDirectory;
        };

        modules = [
          ./darwin
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # `extraSpecialArgs` is the home-manager equivalent of
            # `specialArgs`: arbitrary values forwarded into every home-manager
            # module's function arguments.
            # Here we pass the full `inputs` attrset so that modules in
            # `home/default.nix` can reference other flake inputs (e.g.
            # overlays, plugins) without those inputs having to be declared
            # as options.
            home-manager.extraSpecialArgs = {
              inherit inputs;
            };
            home-manager.users.${host.username} = mkHomeModule host;
          }
        ];
      };
    in {
      # Export only Darwin hosts as nix-darwin configurations.
      darwinConfigurations = lib.mapAttrs mkDarwin (lib.filterAttrs (_: host: isDarwin host) hosts);

      # Export only non-Darwin hosts as standalone Home Manager configs.
      homeConfigurations = lib.mapAttrs mkHome (lib.filterAttrs (_: host: !isDarwin host) hosts);
    };
}
