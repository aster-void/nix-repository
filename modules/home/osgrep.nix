{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.osgrep;
  osgrepPackage = import ../../packages/osgrep {inherit pkgs;};
in {
  _class = "homeManager";

  options.programs.osgrep = {
    enable = lib.mkEnableOption "osgrep semantic code search";
    package = lib.mkOption {
      type = lib.types.package;
      default = osgrepPackage;
      description = "The osgrep package to use";
    };
    enableClaudeCodeIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Claude Code integration with automatic osgrep serve management";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      home.packages = [cfg.package];
    })

    (lib.mkIf (cfg.enable && cfg.enableClaudeCodeIntegration) {
      programs.claude-code = {
        hooks = {
          "session-start" = ''
            #!/usr/bin/env bash
            # Start osgrep serve in background
            if ! pgrep -f "osgrep serve" > /dev/null; then
              nohup ${cfg.package}/bin/osgrep serve > /tmp/osgrep.log 2>&1 &
              echo "osgrep serve started"
            fi
          '';

          "session-end" = ''
            #!/usr/bin/env bash
            # Stop osgrep serve
            if [ -f .osgrep/server.json ]; then
              PID=$(${pkgs.jq}/bin/jq -r '.pid' .osgrep/server.json 2>/dev/null)
              if [ -n "$PID" ] && [ "$PID" != "null" ]; then
                kill -TERM "$PID" 2>/dev/null || true
              fi
              rm -f .osgrep/server.json
            fi
            # Fallback: pkill
            pkill -f "osgrep serve" 2>/dev/null || true
          '';
        };
      };
    })
  ];
}
