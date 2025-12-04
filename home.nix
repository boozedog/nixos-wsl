{ pkgs, ... }:
{
  home = {
    username = "david";
    homeDirectory = "/home/david";
    stateVersion = "25.05";
  };

  # Disable manual generation to avoid warnings
  manual = {
    html.enable = false;
    json.enable = false;
    manpages.enable = false;
  };

  # SSH Agent Bridge for Bitwarden (Windows -> WSL)
  systemd.user.services.ssh-agent-bridge =
    let
      npiperelay-wrapper = pkgs.writeShellScript "npiperelay-wrapper" ''
        exec "/mnt/c/Program Files/WinGet/Links/npiperelay.exe" "$@"
      '';
    in
    {
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
  programs = {
    # shells
    bash = {
      enable = true;
      initExtra = ''
        export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"
      '';
    };

    fish = {
      enable = true;
      interactiveShellInit = ''
        set -g fish_greeting
      '';
      plugins = [
        {
          name = "autopair";
          inherit (pkgs.fishPlugins.autopair) src;
        }
        {
          name = "done";
          inherit (pkgs.fishPlugins.done) src;
        }
        {
          name = "forgit";
          inherit (pkgs.fishPlugins.forgit) src;
        }
        {
          name = "fzf-fish";
          inherit (pkgs.fishPlugins.fzf-fish) src;
        }
        {
          name = "sponge";
          inherit (pkgs.fishPlugins.sponge) src;
        }
      ];
      shellAbbrs = {
        ai = "aichat";
        l = "ls -lah";
        ls = "eza --long --all --git";
        vi = "hx";
        vim = "hx";
      };
      shellInit = ''
        set -gx SSH_AUTH_SOCK $HOME/.ssh/agent.sock
      '';
    };

    zsh.enable = true;

    # utilities
    aichat.enable = true;
    git = {
      enable = true;
      settings = {
        user = {
          name = "boozedog";
          email = "code@booze.dog";
        };
        core.editor = "hx";
      };
    };
    eza = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      git = true;
    };
    fzf = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };
    ripgrep.enable = true;
    starship = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      settings = {
        format = "$all$cmd_duration$custom";
        character.disabled = true;
        custom.prompt_symbol = {
          command = ''
            case "$STARSHIP_SHELL" in
              bash) printf '$' ;;
              zsh) printf '%%' ;;
              fish) printf '>' ;;
              *) printf '?' ;;
            esac
          '';
          when = true;
          format = "[$output](bold green) ";
          shell = [
            "bash"
            "--noprofile"
            "--norc"
          ];
        };
      };
    };
    tmux.enable = true;
    trippy = {
      enable = true;
      settings.trippy.mode = "tui";
    };
    zoxide = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };

    # Let home-manager manage itself
    home-manager.enable = true;
  };
}
