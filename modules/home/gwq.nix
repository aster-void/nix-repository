{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.gwq;
  gwqPackage = import ../../packages/gwq {inherit pkgs;};

  tomlFormat = pkgs.formats.toml {};

  sanitizeCharsType = lib.types.attrsOf lib.types.str;
in {
  _class = "homeManager";

  options.programs.gwq = {
    enable = lib.mkEnableOption "gwq Git worktree manager";

    package = lib.mkOption {
      type = lib.types.package;
      default = gwqPackage;
      description = "The gwq package to use";
    };

    settings = lib.mkOption {
      type = tomlFormat.type;
      default = {};
      description = ''
        Configuration written to {file}`$XDG_CONFIG_HOME/gwq/config.toml`.
        See <https://github.com/d-kuro/gwq> for supported values.
      '';
      example = lib.literalExpression ''
        {
          worktree = {
            basedir = "~/worktrees";
            auto_mkdir = true;
          };
          finder = {
            preview = true;
            preview_size = 3;
          };
          naming = {
            template = "{{.Host}}/{{.Owner}}/{{.Repository}}/{{.Branch}}";
            sanitize_chars = {
              "/" = "-";
              ":" = "-";
            };
          };
          ui = {
            icons = true;
            tilde_home = true;
          };
          tmux = {
            enabled = true;
            tmux_command = "tmux";
            history_limit = 50000;
          };
          claude = {
            executable = "claude";
            timeout = "30m";
            max_parallel = 3;
            config_dir = "~/.config/gwq/claude";
            task = {
              queue_dir = "~/.config/gwq/claude/queue";
              log_retention_days = 30;
              max_log_size_mb = 100;
              auto_cleanup = true;
            };
          };
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [cfg.package];

    xdg.configFile."gwq/config.toml" = lib.mkIf (cfg.settings != {}) {
      source = tomlFormat.generate "gwq-config.toml" cfg.settings;
    };
  };
}
