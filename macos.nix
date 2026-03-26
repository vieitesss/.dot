{ pkgs, inputs, self, ... }:
let
  sharedPackages = import ./packages/shared.nix {
    inherit pkgs inputs;
  };

  macosPackages = import ./packages/macos.nix {
    inherit pkgs;
  };
in
{
  nix.settings.experimental-features = "nix-command flakes";

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  system.primaryUser = "vieitesprefapp";
  system.stateVersion = 6;
  system.configurationRevision = self.rev or self.dirtyRev or null;

  environment.systemPackages = sharedPackages ++ macosPackages;

  homebrew = {
    enable = true;

    brews = [
      "mole"
    ];

    casks = [
      "aldente"
      "brave-browser"
      "nikitabobko/tap/aerospace"
      "codexbar"
      "cmux"
      "hammerspoon"
      "karabiner-elements"
      "raycast"
      "shottr"
      "monitorcontrol"
      "logi-options+"
    ];

    onActivation = {
      cleanup = "none";
      autoUpdate = true;
      upgrade = true;
    };
  };
}
