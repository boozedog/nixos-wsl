# nixos-wsl

## rebuild

```sh
sudo nixos-rebuild switch --flake .#nixos
```

## other stuff

```sh
# connect wsl ssh agent to bitwarden ssh agent on windows host
source ~/projects/nixos-wsl/scripts/agent-bridge.sh
```
