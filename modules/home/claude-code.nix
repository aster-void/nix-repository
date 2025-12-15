{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.claude-code;

  # Resolve path from plugin.json (handles "./path" format)
  resolvePath = src: path:
    if lib.hasPrefix "./" path
    then "${src}/${lib.removePrefix "./" path}"
    else "${src}/${path}";

  # Collect plugin info (with plugin.json support)
  collectPluginInfo = plugin: let
    src =
      if lib.isPath plugin
      then plugin
      else plugin.src;
    opts =
      if lib.isPath plugin
      then {
        name = null;
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

    # Get name: user-provided > plugin.json > directory basename (strip store hash)
    baseName = baseNameOf (toString src);
    # Store paths look like "hash-name", extract just the name
    strippedName = let
      parts = builtins.match "[a-z0-9]+-(.+)" baseName;
    in
      if parts != null
      then builtins.head parts
      else baseName;
    name =
      if opts.name != null
      then opts.name
      else if hasPluginJson && pluginJson ? name
      then pluginJson.name
      else strippedName;

    getPath = key: default:
      if hasPluginJson && pluginJson ? ${key}
      then resolvePath src pluginJson.${key}
      else "${src}/${default}";

    commandsPath = getPath "commands" "commands";
    agentsPath = getPath "agents" "agents";
    skillsPath = getPath "skills" "skills";
  in {
    inherit name;
    commands =
      if opts.commands && builtins.pathExists commandsPath
      then commandsPath
      else null;
    agents =
      if opts.agents && builtins.pathExists agentsPath
      then agentsPath
      else null;
    skills =
      if opts.skills && builtins.pathExists skillsPath
      then skillsPath
      else null;
  };

  pluginInfos = map collectPluginInfo cfg.plugins;

  # Generate home.file entries - merge into ~/.claude/{commands,agents,skills}/{name}/
  mkPluginFileEntries = info:
    lib.optionalAttrs (info.commands != null) {
      ".claude/commands/${info.name}" = {
        source = info.commands;
        recursive = true;
      };
    }
    // lib.optionalAttrs (info.agents != null) {
      ".claude/agents/${info.name}" = {
        source = info.agents;
        recursive = true;
      };
    }
    // lib.optionalAttrs (info.skills != null) {
      ".claude/skills/${info.name}" = {
        source = info.skills;
        recursive = true;
      };
    };

  allPluginFileEntries = lib.foldl' (acc: entry: acc // entry) {} (map mkPluginFileEntries pluginInfos);

  pluginSubmodule = lib.types.submodule {
    options = {
      src = lib.mkOption {type = lib.types.path;};
      name = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Plugin name (auto-detected from plugin.json or directory name)";
      };
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
    plugins = lib.mkOption {
      type = lib.types.listOf (lib.types.coercedTo lib.types.path (src: {inherit src;}) pluginSubmodule);
      default = [];
      example = lib.literalExpression ''
        [
          (pkgs.fetchFromGitHub {
            owner = "someone";
            repo = "claude-plugins";
            rev = "v1.0.0";
            hash = "sha256-...";
          })
          {
            src = ./my-plugin;
            name = "my-plugin";  # optional, auto-detected
            commands = true;
            skills = false;
          }
        ]
      '';
      description = "Plugins to import (commands/agents/skills from external sources)";
    };
  };

  config = lib.mkIf cfg.enable {
    home.file = allPluginFileEntries;
  };
}
