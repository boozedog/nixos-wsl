# nixos-wsl

## update home-manager config only

```sh
nix run github:nix-community/home-manager#home-manager -- switch --flake .
# reload fish config
source ~/.config/fish/config.fish
# reload zsh config
. ~/.zshrc
```

## rebuild

```sh
sudo nixos-rebuild switch --flake .#nixos
```

## other stuff

```sh
# connect wsl ssh agent to bitwarden ssh agent on windows host
source ~/projects/nixos-wsl/scripts/agent-bridge.sh
```
