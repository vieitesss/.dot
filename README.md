# Dotfiles

- `flake.nix`: flake inputs and the exported `macos` configuration.
- `macos.nix`: main macOS configuration, plus Homebrew settings.
- `packages/shared.nix`: packages you want available everywhere.
- `packages/macos.nix`: packages that only belong to this macOS setup.
- `justfile`: shortcuts for `darwin-rebuild`.
