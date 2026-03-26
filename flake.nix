{
  description = "Personal cross-platform dotfiles flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, ... }:
    let
      lib = nixpkgs.lib;
      isDarwin = host: lib.hasSuffix "darwin" host.system;
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
      hosts = lib.mapAttrs (_: host: mkHost host) (import ./hosts.nix);
      mkPkgs = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      mkHomeModule = host: {
        imports = [ ./home.nix ];
        home = {
          inherit (host) username homeDirectory;
        };
      };
      mkHome = _: host: home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs host.system;
        extraSpecialArgs = {
          inherit inputs;
        };
        modules = [ (mkHomeModule host) ];
      };
      mkDarwin = hostName: host: nix-darwin.lib.darwinSystem {
        system = host.system;
        specialArgs = {
          inherit self hostName;
          inherit (host) flakeDirectory username homeDirectory;
        };
        modules = [
          ./macos.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit inputs;
            };
            home-manager.users.${host.username} = mkHomeModule host;
          }
        ];
      };
    in {
      darwinConfigurations = lib.mapAttrs mkDarwin (lib.filterAttrs (_: host: isDarwin host) hosts);

      homeConfigurations = lib.mapAttrs mkHome (lib.filterAttrs (_: host: !isDarwin host) hosts);
    };
}
