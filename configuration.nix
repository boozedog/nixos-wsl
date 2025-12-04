# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, ... }:

{
  imports = [
    # NixOS-WSL module is now imported via flake
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];

    # Add Determinate Systems binary cache
    extra-substituters = [ "https://install.determinate.systems" ];
    extra-trusted-public-keys = [ "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM=" ];
  };

  # Since Determinate Nix installer is already managing Nix,
  # the determinate module in the flake provides the integration.
  # Custom settings would be configured via the Determinate Nix installer
  # or in /etc/nix/nix.custom.conf if using Determinate Nix 3.x

  wsl = {
    enable = true;
    defaultUser = "david";
    interop.register = true;
  };

  programs = {
    direnv = {
      enable = true;
      enableFishIntegration = true;
      nix-direnv.enable = true;
    };
    fish.enable = true;
    nix-ld.enable = true;
  };

  environment = {
    systemPackages = with pkgs; [
      # Development tools
      aichat
      devbox
      git
      git-extras
      helix
      neovim
      tree

      # Language servers
      awk-language-server
      dockerfile-language-server
      nil
      nixd
      nodePackages.vscode-json-languageserver

      # Nix tools
      nixfmt-rfc-style
      nodePackages.npm-check-updates

      # System tools
      socat
    ];

    variables = {
      EDITOR = "hx";
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
