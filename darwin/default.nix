{ self, username, homeDirectory, ... }:
{
  imports = [ ./auto-upgrade.nix ];

  nix.settings.experimental-features = "nix-command flakes";

  nixpkgs.config.allowUnfree = true;

  users.users.${username} = {
    name = username;
    home = homeDirectory;
  };

  system.primaryUser = username;
  system.stateVersion = 6;
  system.configurationRevision = self.rev or self.dirtyRev or null;

  homebrew = {
    enable = true;

    brews = [
      "mole"
    ];

    casks = [
      "aldente"
      "biscuit"
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
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
  };
}
