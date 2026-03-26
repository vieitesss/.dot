host := "macos"

alias drs := switch

_default:
	just -l

build:
	darwin-rebuild build --flake .#{{host}}

switch:
	sudo darwin-rebuild switch --flake .#{{host}}
