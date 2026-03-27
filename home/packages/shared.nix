{ pkgs, inputs }:
let
  system = pkgs.stdenv.hostPlatform.system;
in
with pkgs; [
  actionlint
  awscli2
  bat
  bun
  cloudflared
  delta
  eza
  fd
  fzf
  gh
  git
  go
  htop
  just
  k9s
  kind
  kubectl
  nodejs_24
  opencode
  p7zip
  ripgrep
  ruby_3_4
  rustup
  stow
  tmux
  vim
  wget
  yq-go
  zoxide
  inputs.neovim-nightly-overlay.packages.${system}.default
]
