{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.claude-code;
  jsonFormat = pkgs.formats.json {};

  # Build settings.json content
  settingsContent =
    {}
    // lib.optionalAttrs (cfg.settings.permissions.allow != [] || cfg.settings.permissions.deny != []) {
      permissions =
        lib.optionalAttrs (cfg.settings.permissions.allow != []) {
          allow = cfg.settings.permissions.allow;
        }
        // lib.optionalAttrs (cfg.settings.permissions.deny != []) {
          deny = cfg.settings.permissions.deny;
        };
    }
    // lib.optionalAttrs (cfg.settings.hooks != {}) {
      hooks = lib.mapAttrs (_event: rules:
        map (rule:
          lib.optionalAttrs (rule.matcher != null) {inherit (rule) matcher;}
          // {
            hooks = map (h:
              {inherit (h) type timeout;}
              // lib.optionalAttrs (h.command != null) {inherit (h) command;}
              // lib.optionalAttrs (h.prompt != null) {inherit (h) prompt;})
            rule.hooks;
          })
        rules)
      cfg.settings.hooks;
    }
    // cfg.extraSettings;

  # Resolve path from plugin.json (handles "./path" format)
  resolvePath = src: path:
    if lib.hasPrefix "./" path
    then "${src}/${lib.removePrefix "./" path}"
    else "${src}/${path}";

  # Collect plugin files (with plugin.json support)
  collectPluginFiles = plugin: let
    src =
      if lib.isPath plugin
      then plugin
      else plugin.src;
    opts =
      if lib.isPath plugin
      then {
        commands = true;
        agents = true;
        skills = true;
      }
      else plugin;

    pluginJsonPath = "${src}/.claude-plugin/plugin.json";
    hasPluginJson = builtins.pathExists pluginJsonPath;
    pluginJson =
      if hasPluginJson
      then builtins.fromJSON (builtins.readFile pluginJsonPath)
      else {};

    # Get path from plugin.json or use default
    getPath = key: default:
      if hasPluginJson && pluginJson ? ${key}
      then resolvePath src pluginJson.${key}
      else "${src}/${default}";

    commandsPath = getPath "commands" "commands";
    agentsPath = getPath "agents" "agents";
    skillsPath = getPath "skills" "skills";
  in
    lib.optionalAttrs (opts.commands && builtins.pathExists commandsPath) {
      commands = commandsPath;
    }
    // lib.optionalAttrs (opts.agents && builtins.pathExists agentsPath) {
      agents = agentsPath;
    }
    // lib.optionalAttrs (opts.skills && builtins.pathExists skillsPath) {
      skills = skillsPath;
    };

  pluginFiles = map collectPluginFiles cfg.plugins;

  # Generate home.file entries for plugins
  mkPluginFileEntries = idx: files:
    lib.optionalAttrs (files ? commands) {
      ".claude/plugins/${toString idx}/commands" = {
        source = files.commands;
        recursive = true;
      };
    }
    // lib.optionalAttrs (files ? agents) {
      ".claude/plugins/${toString idx}/agents" = {
        source = files.agents;
        recursive = true;
      };
    }
    // lib.optionalAttrs (files ? skills) {
      ".claude/plugins/${toString idx}/skills" = {
        source = files.skills;
        recursive = true;
      };
    };

  allPluginFileEntries = lib.foldl' (acc: entry: acc // entry) {} (lib.imap0 mkPluginFileEntries pluginFiles);

  hookSubmodule = lib.types.submodule {
    options = {
      type = lib.mkOption {
        type = lib.types.enum ["command" "prompt"];
        default = "command";
      };
      command = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      prompt = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      timeout = lib.mkOption {
        type = lib.types.int;
        default = 60;
      };
    };
  };

  hookRuleSubmodule = lib.types.submodule {
    options = {
      matcher = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "Bash|Edit";
      };
      hooks = lib.mkOption {
        type = lib.types.listOf hookSubmodule;
        default = [];
      };
    };
  };

  pluginSubmodule = lib.types.submodule {
    options = {
      src = lib.mkOption {type = lib.types.path;};
      commands = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      agents = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      skills = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
    };
  };
in {
  _class = "homeManager";

  options.programs.claude-code = {
    settings = {
      permissions = {
        allow = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          example = ["Bash(git:*)" "Read" "Write"];
          description = "Allowed tool patterns";
        };
        deny = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          example = ["Bash(rm -rf:*)"];
          description = "Denied tool patterns";
        };
      };

      hooks = lib.mkOption {
        type = lib.types.attrsOf (lib.types.listOf hookRuleSubmodule);
        default = {};
        example = {
          PreToolUse = [
            {
              matcher = "Bash";
              hooks = [
                {
                  type = "command";
                  command = "echo 'before'";
                }
              ];
            }
          ];
        };
        description = "Hooks configuration (written to settings.json)";
      };
    };

    extraSettings = lib.mkOption {
      type = lib.types.attrsOf jsonFormat.type;
      default = {};
      example = {
        theme = "dark";
        model = "claude-sonnet-4-20250514";
      };
      description = "Additional settings to merge into settings.json";
    };

    plugins = lib.mkOption {
      type = lib.types.listOf (lib.types.coercedTo lib.types.path (src: {inherit src;}) pluginSubmodule);
      default = [];
      example = lib.literalExpression ''
        [
          (pkgs.fetchFromGitHub {
            owner = "wshobson";
            repo = "commands";
            rev = "main";
            hash = "sha256-...";
          })
          {
            src = ./my-plugin;
            commands = true;
            skills = false;
          }
        ]
      '';
      description = "Plugins to import (commands/agents/skills from external sources)";
    };
  };

  config = lib.mkIf cfg.enable {
    home.file =
      lib.optionalAttrs (settingsContent != {}) {
        ".claude/settings.json".source = jsonFormat.generate "claude-settings.json" (
          settingsContent // {"$schema" = "https://json.schemastore.org/claude-code-settings.json";}
        );
      }
      // allPluginFileEntries;
  };
}
