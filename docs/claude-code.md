# Claude Code (Home Manager Extension)

Extension module for Home Manager's `programs.claude-code` with type-safe settings and plugin support.

## Usage

```nix
{ inputs, pkgs, ... }:
{
  imports = [
    inputs.nix-repository.homeModules.claude-code
  ];

  programs.claude-code = {
    enable = true;  # from upstream HM module

    # Type-safe settings (this module)
    settings = {
      permissions.allow = [ "Bash(git:*)" "Read" ];
      hooks.PreToolUse = [{
        matcher = "Bash";
        hooks = [{ type = "command"; command = "echo $TOOL_INPUT"; }];
      }];
    };

    extraSettings.theme = "dark";

    plugins = [
      (pkgs.fetchFromGitHub {
        owner = "wshobson";
        repo = "commands";
        rev = "v1.0.0";  # use tag or commit hash, not branch
        hash = "sha256-...";
      })
    ];
  };
}
```

## Options

### `settings.permissions`

| Option  | Type           | Default | Description           |
| ------- | -------------- | ------- | --------------------- |
| `allow` | list of string | `[]`    | Allowed tool patterns |
| `deny`  | list of string | `[]`    | Denied tool patterns  |

Example patterns: `"Bash(git:*)"`, `"Read"`, `"Write"`, `"Bash(rm -rf:*)"`

### `settings.hooks`

Attribute set mapping event names to hook rules. Written to `settings.json`.

```nix
settings.hooks = {
  PreToolUse = [{
    matcher = "Bash|Edit";  # regex pattern, null = all
    hooks = [
      { type = "command"; command = "my-validator $TOOL_INPUT"; timeout = 60; }
    ];
  }];
  Stop = [{
    hooks = [
      { type = "prompt"; prompt = "Summarize changes"; timeout = 30; }
    ];
  }];
};
```

**Events**: `PreToolUse`, `PostToolUse`, `PermissionRequest`, `Notification`, `UserPromptSubmit`, `Stop`, `SubagentStop`, `PreCompact`, `SessionStart`, `SessionEnd`

**Hook types**:

- `command`: Shell command (`command` field)
- `prompt`: AI prompt (`prompt` field)

### `extraSettings`

Additional settings merged into `settings.json`. Free-form JSON.

```nix
extraSettings = {
  theme = "dark";
  model = "claude-sonnet-4-20250514";
};
```

### `plugins`

Import commands/agents/skills from external sources.

```nix
plugins = [
  # From GitHub (use tag or commit hash)
  (pkgs.fetchFromGitHub {
    owner = "someone";
    repo = "claude-plugins";
    rev = "v1.0.0";
    hash = "sha256-...";
  })

  # Subpath import (monorepo with multiple plugins)
  ((pkgs.fetchFromGitHub {
    owner = "someone";
    repo = "dotfiles";
    rev = "abc1234";
    hash = "sha256-...";
  }) + "/claude/my-plugin")

  # Local path
  ./my-local-plugin

  # Selective import
  {
    src = ./my-plugin;
    commands = true;
    agents = true;
    skills = false;
  }
];
```

**Plugin structure** (auto-detected):

```
plugin/
├── .claude-plugin/
│   └── plugin.json      # Optional: custom paths
├── commands/            # Default: commands/
├── agents/              # Default: agents/
└── skills/              # Default: skills/
```

**plugin.json format**:

```json
{
  "name": "my-plugin",
  "commands": "./custom/commands/",
  "agents": "./agents/",
  "skills": "./my-skills/"
}
```

## Generated Files

| Source                  | Destination                      |
| ----------------------- | -------------------------------- |
| `settings.*`            | `~/.claude/settings.json`        |
| `plugins[n].commands/*` | `~/.claude/plugins/n/commands/*` |
| `plugins[n].agents/*`   | `~/.claude/plugins/n/agents/*`   |
| `plugins[n].skills/*`   | `~/.claude/plugins/n/skills/*`   |
