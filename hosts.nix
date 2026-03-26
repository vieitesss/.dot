{
  # Host entries are keyed by the machine's real short hostname.
  # - macOS: `scutil --get LocalHostName`
  # - Linux: `hostname -s`
  #
  # Each host usually only needs:
  # - `system`: Nix platform string such as `aarch64-darwin` or `x86_64-linux`
  #   Get it on the target machine with:
  #   `nix eval --impure --raw --expr builtins.currentSystem`
  # - `username`: local login user that Home Manager should manage
  #
  # Optional overrides:
  # - `homeDirectory`: defaults to `/Users/<username>` on macOS and `/home/<username>` on Linux
  # - `flakeDirectory`: defaults to `<homeDirectory>/.dot`
  MacBook-Air-de-Daniel = {
    system = "aarch64-darwin";
    username = "vieitesprefapp";
  };
}
