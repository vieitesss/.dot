current_host := `if [ "$(uname -s)" = "Darwin" ]; then scutil --get LocalHostName; else hostname -s; fi`
current_flake := "path:.#{{current_host}}"

alias drs := switch
alias hms := hm-switch

_default:
	just -l

build:
	printf 'Using host %s\n' "{{current_host}}"; if [ "$(uname -s)" = "Darwin" ]; then darwin-rebuild build --flake "{{current_flake}}"; else home-manager build --flake "{{current_flake}}"; fi

switch:
	printf 'Using host %s\n' "{{current_host}}"; if [ "$(uname -s)" = "Darwin" ]; then sudo darwin-rebuild switch --flake "{{current_flake}}"; else home-manager switch --flake "{{current_flake}}"; fi

hm-build target:
	home-manager build --flake path:.#{{target}}

hm-switch target:
	home-manager switch --flake path:.#{{target}}
