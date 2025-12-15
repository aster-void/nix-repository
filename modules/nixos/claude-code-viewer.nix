{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.claude-code-viewer;
  claudeCodeViewerPackage = import ../../packages/claude-code-viewer {inherit pkgs;};

  wrappedClaude =
    if cfg.claudeCode.extraFlags == []
    then cfg.claudeCode.package
    else
      pkgs.runCommand "claude-wrapped" {
        nativeBuildInputs = [pkgs.makeBinaryWrapper];
      } ''
        mkdir -p $out/bin
        makeBinaryWrapper ${lib.getExe cfg.claudeCode.package} $out/bin/claude \
          --add-flags ${lib.escapeShellArg (lib.concatStringsSep " " cfg.claudeCode.extraFlags)}
      '';
in {
  _class = "nixos";

  options.services.claude-code-viewer = {
    enable = lib.mkEnableOption "Claude Code Viewer web service";

    package = lib.mkOption {
      type = lib.types.package;
      default = claudeCodeViewerPackage;
      description = "The claude-code-viewer package to use";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3400;
      description = "Port to listen on";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "localhost";
      description = "Host address to bind to";
    };

    user = lib.mkOption {
      type = lib.types.str;
      description = ''
        User account under which claude-code-viewer runs.
        This should typically be your regular user account so the service
        can access Claude Code session data in your home directory.
      '';
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "users";
      description = "Group under which claude-code-viewer runs";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open the firewall for the claude-code-viewer port";
    };

    claudeCode.package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.claude-code;
      description = "The Claude Code package to use";
    };

    claudeCode.extraFlags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = ["--model" "opus"];
      description = "Extra flags to pass to the Claude Code CLI";
    };

    extraEnv = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      example = {
        ANTHROPIC_API_KEY = "sk-...";
      };
      description = ''
        Extra environment variables for claude-code-viewer service.
      '';
    };

    passwordFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to a file containing the authentication password.
        When set, enables password-based authentication to protect access.
        The file should contain the password as plain text.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.claude-code-viewer = {
      description = "Claude Code Viewer web service";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];

      environment =
        {
          PORT = toString cfg.port;
          HOST = cfg.host;
          NODE_ENV = "production";
          SHELL = "/bin/sh";
        }
        // {
          CLAUDE_CODE_VIEWER_CC_EXECUTABLE_PATH = lib.getExe wrappedClaude;
        }
        // cfg.extraEnv;

      serviceConfig =
        {
          Type = "simple";
          User = cfg.user;
          Group = cfg.group;
          Restart = "always";
          RestartSec = 5;

          # Hardening - allow reading home directory for Claude Code session data
          NoNewPrivileges = true;
          PrivateTmp = true;
          ProtectSystem = "strict";
        }
        // lib.optionalAttrs (cfg.passwordFile != null) {
          LoadCredential = "password:${cfg.passwordFile}";
        }
        // lib.optionalAttrs (cfg.passwordFile == null) {
          ExecStart = lib.getExe cfg.package;
        };

      script = lib.mkIf (cfg.passwordFile != null) ''
        export CLAUDE_CODE_VIEWER_AUTH_PASSWORD=$(cat "$CREDENTIALS_DIRECTORY/password")
        exec ${lib.getExe cfg.package}
      '';
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];
  };
}
