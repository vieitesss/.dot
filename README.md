# Dotfiles

Personal cross-platform dotfiles managed with Nix.

- macOS uses `nix-darwin` plus Home Manager.
- Linux uses standalone Home Manager.

## Bootstrap

1. Install Nix.
2. Clone this repo to `~/.dot`.
3. Apply the configuration for the current host.

macOS:

```sh
nix run github:nix-darwin/nix-darwin/master#darwin-rebuild -- switch --flake ~/.dot#<hostname>
```

Linux:

```sh
nix run github:nix-community/home-manager -- switch --flake ~/.dot#<hostname>
```

If flakes are not enabled yet, add `--extra-experimental-features 'nix-command flakes'` to the command.

The `<hostname>` value must match the key used in `hosts.nix`.

## Daily Use

| Command | Effect |
| --- | --- |
| `just build` | Build the configuration for the current machine |
| `just switch` | Apply the configuration for the current machine |
| `just hm-build <host>` | Build a specific Linux Home Manager target |
| `just hm-switch <host>` | Apply a specific Linux Home Manager target |

## Adding A Machine

1. Find the machine's real short hostname:
   - macOS: `scutil --get LocalHostName`
   - Linux: `hostname -s`
2. Add an entry to `hosts.nix` using that hostname as the attribute name.
3. Set `system` to the target platform string, for example `aarch64-darwin`, `x86_64-linux`, or `aarch64-linux`.
4. Set `username` to the local account that Home Manager should manage.
5. Override `homeDirectory` or `flakeDirectory` only when the machine uses a non-standard path.

You can get the `system` value on the target machine with:

```sh
nix eval --impure --raw --expr builtins.currentSystem
```

## Repository Layout

```text
darwin/            # nix-darwin system-level modules for macOS
  default.nix      # main macOS settings, users, Homebrew
  auto-upgrade.nix # scheduled darwin-rebuild and Nix garbage collection
home/              # Home Manager user-level modules shared across platforms
  default.nix      # shared user configuration entry point
  packages/
    shared.nix     # packages installed everywhere
    darwin.nix     # extra packages installed only on macOS
flake.nix          # flake inputs, host normalization, exported outputs
hosts.nix          # machine inventory keyed by real hostname
justfile           # convenience commands for build and switch flows
```

## Notes

- `flake.nix` exports Darwin hosts as `darwinConfigurations` and non-Darwin hosts as `homeConfigurations`.
- On macOS, Home Manager is embedded inside `nix-darwin`, so user configuration still lives under `home/`.
- Automatic upgrade logs live at `/var/log/darwin-auto-upgrade.log`.
- The automatic `darwin-rebuild` job runs daily at 02:00.
- Nix garbage collection runs weekly on Sunday at 03:15 and deletes generations older than 30 days.
