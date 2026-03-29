{ config, lib, pkgs, flakeDirectory, hostName, username, ... }:

let
  flakeDir = flakeDirectory;
  flakeRef = "path:${flakeDir}#${hostName}";
  upgradeLogFile = "/var/log/darwin-auto-upgrade.log";
  upgradeScript = pkgs.writeShellScript "darwin-auto-upgrade" ''
    set -euo pipefail

    flake_dir=${lib.escapeShellArg flakeDir}
    flake_ref=${lib.escapeShellArg flakeRef}

    # Update flake inputs as the regular user to preserve flake.lock ownership.
    # GIT_CONFIG_COUNT/KEY/VALUE mark the flake dir as a safe git directory so
    # that nix can read it; GIT_CONFIG_NOSYSTEM + the custom safe.directory
    # entry prevent git from refusing to write the lock file due to ownership.
    sudo -u ${lib.escapeShellArg username} \
      HOME=${lib.escapeShellArg "/Users/${username}"} \
      ${pkgs.nix}/bin/nix flake update --flake "$flake_dir"

    export HOME="/var/root"
    export GIT_CONFIG_COUNT=1
    export GIT_CONFIG_KEY_0="safe.directory"
    export GIT_CONFIG_VALUE_0="$flake_dir"

    ${config.system.build.darwin-rebuild}/bin/darwin-rebuild switch \
      --flake "$flake_ref" \
      --print-build-logs
  '';
in
{
  launchd.daemons.darwin-auto-upgrade = {
    command = "${upgradeScript}";
    serviceConfig = {
      Label = "dev.vieitesss.darwin-auto-upgrade.${hostName}";
      LowPriorityIO = true;
      ProcessType = "Background";
      RunAtLoad = false;
      StartCalendarInterval = [
        {
          Hour = 2;
          Minute = 0;
        }
      ];
      StandardOutPath = upgradeLogFile;
      StandardErrorPath = upgradeLogFile;
    };
  };

  nix.gc = {
    automatic = true;
    interval = [
      {
        Weekday = 7;
        Hour = 3;
        Minute = 15;
      }
    ];
    options = "--delete-older-than 30d";
  };
}
