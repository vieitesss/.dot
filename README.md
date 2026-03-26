# Dotfiles

- `flake.nix`: flake inputs plus exported `darwinConfigurations` and Linux `homeConfigurations`.
- `hosts.nix`: machine inventory keyed by the real hostname of each machine.
- `auto-upgrade.nix`: scheduled `darwin-rebuild` runs plus Nix garbage collection.
- `macos.nix`: macOS system settings managed by `nix-darwin`.
- `home.nix`: shared Home Manager configuration plus small platform-specific conditionals.
- `packages/shared.nix`: packages you want available everywhere.
- `packages/macos.nix`: packages that only belong to the macOS setup.
- `justfile`: shortcuts for `darwin-rebuild` and `home-manager`.

`nix-darwin` stays for macOS because this repo manages system-level things there, such as Homebrew and launchd automation. Linux stays on standalone Home Manager.

`hosts.nix` is the machine inventory for the whole flake. Each attribute name must match the real short hostname of that machine:

- macOS: `scutil --get LocalHostName`
- Linux: `hostname -s`

Each host entry usually only needs:

- `system`: Nix platform string such as `aarch64-darwin`, `x86_64-linux`, or `aarch64-linux`.
- `username`: local user that Home Manager should manage.

Optional overrides per host:

- `homeDirectory`: defaults to `/Users/<username>` on macOS and `/home/<username>` on Linux.
- `flakeDirectory`: defaults to `<homeDirectory>/.dot`.

To add a new machine, copy an existing entry in `hosts.nix`, rename the key to the real hostname, set `system` and `username`, then add overrides only if that machine uses a non-standard home path or checkout location.

Useful commands:

- `just build`: detect the current machine and build its config.
- `just switch`: detect the current machine and switch its config.
- `just hm-build <target>`: build a specific Linux Home Manager target by hostname.
- `just hm-switch <target>`: switch a specific Linux Home Manager target by hostname.

Automatic upgrade logs live at `/var/log/darwin-auto-upgrade.log`.
