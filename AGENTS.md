# AGENTS.md

This document provides guidance for AI coding assistants working with this NixOS-WSL configuration repository.

## Repository Overview

This is a NixOS-WSL configuration repository using Nix flakes for declarative system and user environment management. The system runs NixOS on Windows Subsystem for Linux (WSL2) and uses home-manager for user-level configurations.

## Core Technologies

- **Nix Flakes**: Modern Nix dependency management with reproducible builds
- **NixOS-WSL**: NixOS port for Windows Subsystem for Linux
- **home-manager**: Declarative user environment management
- **Determinate Systems**: Enhanced Nix installer and tooling
- **direnv**: Automatic environment loading

## File Structure

- [flake.nix](flake.nix): Main flake configuration with inputs, outputs, and devShell
- [configuration.nix](configuration.nix): System-level NixOS configuration
- [home.nix](home.nix): User-level home-manager configuration for user `david`
- [.nixd.json](.nixd.json): Configuration for nixd language server
- [.envrc](.envrc): direnv configuration for automatic flake environment loading

## Code Standards

### Nix Language Style

1. **Formatting**: Use `alejandra` as the primary formatter (configured in [.nixd.json](.nixd.json#L8-L10))
   - Alternative: `nixpkgs-fmt` is available in devShell
   - Run formatting before committing changes

2. **Attribute Sets**:
   - Use standard Nix attribute set syntax: `{ attr = value; }`
   - Multi-line attribute sets should have one attribute per line
   - Indent with 2 spaces (consistent with existing code)

3. **Function Parameters**:
   - Use pattern matching for common parameters: `{ config, lib, pkgs, ... }:`
   - Ellipsis (`...`) indicates accepting additional arguments

4. **Let Bindings**:
   - Use `let ... in` for local bindings
   - Place related bindings together logically

5. **Comments**:
   - Use `#` for single-line comments
   - Document non-obvious configuration choices
   - Reference upstream documentation when applicable

### Module Organization

1. **configuration.nix** (System-level):
   - Nix settings (experimental features, substituters, caches)
   - WSL-specific configuration
   - System-wide programs and services
   - System packages (development tools, language servers, system utilities)
   - Environment variables
   - Keep `system.stateVersion` unchanged after initial setup

2. **home.nix** (User-level):
   - User identity (`home.username`, `home.homeDirectory`)
   - User services (e.g., systemd user services)
   - Shell configurations (bash, fish, zsh)
   - User programs and tools
   - Shell abbreviations and environment variables
   - Keep `home.stateVersion` unchanged after initial setup

3. **flake.nix**:
   - Input declarations with version pinning
   - Follow nixpkgs for inputs when possible to reduce closure size
   - System architecture definition
   - Module composition in `nixosConfigurations`
   - Standalone home-manager configuration in `homeConfigurations`
   - Development shell with Nix tooling

### Package Management

1. **Adding Packages**:
   - System packages go in [configuration.nix](configuration.nix#L45-L68) `environment.systemPackages`
   - User packages should be added via program-specific home-manager modules in [home.nix](home.nix#L37-L151) when available
   - Use `with pkgs;` for package lists to reduce verbosity

2. **Program Configuration**:
   - Prefer declarative program configuration over manual dotfiles
   - Use home-manager program modules (e.g., `programs.git`, `programs.fish`)
   - Enable shell integrations consistently (e.g., `enableFishIntegration`)

3. **Language Servers**:
   - Language servers go in system packages for system-wide availability
   - Current LSPs: awk-language-server, dockerfile-language-server, nil, nixd, vscode-json-languageserver

### Input Management

1. **Flake Inputs**:
   - Use `follows = "nixpkgs"` for input dependencies to maintain consistency
   - Pin to stable or unstable channels as appropriate
   - Current channel: `nixos-unstable`

2. **Updates**:
   - Run `nix flake update` to update all inputs
   - Run `nix flake lock --update-input <input>` to update specific inputs

### WSL-Specific Considerations

1. **SSH Agent Bridge**:
   - Systemd service bridges Windows SSH agent (Bitwarden) to WSL
   - Uses npiperelay to connect to Windows named pipe
   - Socket located at `$HOME/.ssh/agent.sock`

2. **WSL Interop**:
   - `wsl.interop.register = true` enables Windows binary execution
   - Default user is `david`

3. **Development Environment**:
   - Use direnv for automatic environment loading (`use flake`)
   - devShell includes Nix development tools

## Development Workflow

### Making Changes

1. **System Configuration Changes**:

   ```sh
   # Edit configuration.nix
   sudo nixos-rebuild switch --flake .#nixos
   ```

2. **User Configuration Changes**:

   ```sh
   # Edit home.nix
   nix run github:nix-community/home-manager#home-manager -- switch --flake .
   # Reload shell config if needed
   source ~/.config/fish/config.fish  # for fish
   . ~/.zshrc                          # for zsh
   ```

3. **Flake Changes**:
   - Edit [flake.nix](flake.nix)
   - Run `nix flake check` to validate
   - Rebuild as appropriate

### Development Shell

Enter the development environment with Nix tooling:

```sh
nix develop
# or automatically via direnv (already configured)
```

Available tools in devShell:

- `alejandra`: Nix formatter
- `nixd`: Nix language server
- `nixpkgs-fmt`: Alternative Nix formatter
- `nil`: Nix language server (alternative)
- `statix`: Nix linter

### Code Quality

1. **Linting**: Use `statix` for detecting anti-patterns
2. **Formatting**: Run `alejandra .` before committing
3. **Validation**: Run `nix flake check` to validate flake
4. **Testing**: Test configurations in WSL environment before committing

## Common Patterns

### Adding a New Program

```nix
# In home.nix
programs.newprogram = {
  enable = true;
  enableFishIntegration = true;
  # program-specific options
};
```

### Adding Shell Aliases/Abbreviations

```nix
# In home.nix fish.shellAbbrs
programs.fish.shellAbbrs = {
  shortcut = "full-command";
};
```

### Adding Systemd User Services

```nix
# In home.nix
systemd.user.services.service-name = {
  Unit = {
    Description = "Service description";
  };
  Service = {
    Type = "simple";
    ExecStart = "${pkgs.package}/bin/command";
  };
  Install = {
    WantedBy = [ "default.target" ];
  };
};
```

### Adding System Packages

```nix
# In configuration.nix environment.systemPackages
environment.systemPackages = with pkgs; [
  package-name
];
```

## Important Notes

1. **State Versions**: Never change `system.stateVersion` or `home.stateVersion` after initial setup
2. **Git Configuration**: User identity configured in [home.nix](home.nix#L92-L95) (`boozedog`, `code@booze.dog`)
3. **Default Editor**: Set to `hx` (Helix editor) system-wide and in Git
4. **Default Shell**: Fish shell with custom prompt via Starship
5. **Binary Caches**: Determinate Systems cache configured for faster builds

## Troubleshooting

1. **Build Errors**: Check `nix flake check` for configuration errors
2. **SSH Agent Issues**: Verify systemd service status: `systemctl --user status ssh-agent-bridge`
3. **Permission Issues**: Ensure WSL default user is correctly set
4. **Shell Config**: Source config files after home-manager switch

## Additional Resources

- [NixOS Options Search](https://search.nixos.org/options)
- [home-manager Options](https://nix-community.github.io/home-manager/options.html)
- [NixOS-WSL Documentation](https://github.com/nix-community/NixOS-WSL)
- [Nix Flakes Manual](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html)
