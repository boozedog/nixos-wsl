{ config, pkgs, ... }:

{
  home.username = "david";
  home.homeDirectory = "/home/david";
  home.stateVersion = "25.05";

  # Disable manual generation to avoid warnings
  manual.manpages.enable = false;

  # Environment variables
  home.sessionVariables = {
    SSH_AUTH_SOCK = "$HOME/.ssh/agent.sock";
  };

  # SSH Agent Bridge for Bitwarden (Windows -> WSL)
  systemd.user.services.ssh-agent-bridge =
    let
      npiperelay-wrapper = pkgs.writeShellScript "npiperelay-wrapper" ''
        exec "/mnt/c/Program Files/WinGet/Links/npiperelay.exe" "$@"
      '';
    in {
    Unit = {
      Description = "SSH Agent Bridge to Windows Bitwarden";
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.socat}/bin/socat UNIX-LISTEN:%h/.ssh/agent.sock,fork,unlink-early EXEC:\"${npiperelay-wrapper} -ei -s //./pipe/openssh-ssh-agent\",nofork";
      Restart = "on-failure";
      RestartSec = "1s";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # Shell configuration
  programs.bash = {
    enable = true;
    initExtra = ''
      export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"
    '';
  };

  programs.fish = {
    enable = true;
    shellInit = ''
      set -gx SSH_AUTH_SOCK $HOME/.ssh/agent.sock
    '';
  };

  # Let home-manager manage itself
  programs.home-manager.enable = true;
}
