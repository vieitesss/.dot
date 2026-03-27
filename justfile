current_host := `if [ "$(uname -s)" = "Darwin" ]; then scutil --get LocalHostName; else hostname -s; fi`

alias drs := switch
alias hms := hm-switch

_default:
	just -l

build:
	#!/usr/bin/env bash
	printf 'Using host %s\n' "{{current_host}}"
	if [ "$(uname -s)" = "Darwin" ]
	then
		darwin-rebuild build --flake ".#{{current_host}}"
	else
		home-manager build --flake ".#{{current_host}}"
	fi

switch:
	#!/usr/bin/env bash
	printf 'Using host %s\n' "{{current_host}}"
	if [ "$(uname -s)" = "Darwin" ]
	then
		darwin-rebuild switch --flake ".#{{current_host}}"
	else
		home-manager switch --flake ".#{{current_host}}"
	fi

hm-build target:
	home-manager build --flake path:.#{{target}}

hm-switch target:
	home-manager switch --flake path:.#{{target}}
