{ lib, pkgs, inputs, ... }:

{
  home.packages =
    import ./packages/shared.nix {
      inherit pkgs inputs;
    }
    ++ lib.optionals pkgs.stdenv.isDarwin (import ./packages/darwin.nix {
      inherit pkgs;
    });

  targets.genericLinux.enable = pkgs.stdenv.isLinux;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
