# Claude Code Viewer

A full-featured web-based Claude Code client for managing projects and viewing conversation history.

- Upstream: <https://github.com/d-kimuson/claude-code-viewer>

## Package Usage

```sh
nix run github:aster-void/nix-repository#claude-code-viewer
```

```nix
{ pkgs, inputs, ... }:
{
  home.packages = [
    inputs.nix-repository.packages.${pkgs.system}.claude-code-viewer
  ];
}
```

## NixOS Module

A systemd service module for running claude-code-viewer as a background service.

### Usage

```nix
{ inputs, pkgs, ... }:
{
  imports = [
    inputs.nix-repository.nixosModules.claude-code-viewer
  ];

  services.claude-code-viewer = {
    enable = true;
    user = "your-username";  # Required: user who runs Claude Code
  };
}
```

### Options

| Option         | Type         | Default               | Description                                                                                            |
| -------------- | ------------ | --------------------- | ------------------------------------------------------------------------------------------------------ |
| `enable`       | bool         | `false`               | Enable the Claude Code Viewer service                                                                  |
| `package`      | package      | (this repo's package) | The claude-code-viewer package to use                                                                  |
| `port`         | port         | `3400`                | Port to listen on                                                                                      |
| `host`         | string       | `"localhost"`         | Host address to bind to                                                                                |
| `user`         | string       | (required)            | User account to run the service. Should be your regular user so it can access Claude Code session data |
| `group`        | string       | `"users"`             | Group under which the service runs                                                                     |
| `openFirewall` | bool         | `false`               | Whether to open the firewall for the port                                                              |
| `passwordFile` | path or null | `null`                | Path to a file containing the authentication password                                                  |

### Example with Authentication

```nix
{ inputs, ... }:
{
  imports = [
    inputs.nix-repository.nixosModules.claude-code-viewer
  ];

  services.claude-code-viewer = {
    enable = true;
    user = "aster";
    port = 8080;
    host = "*";  # Listen on all interfaces (IPv4/IPv6)
    openFirewall = true;
    passwordFile = "/run/secrets/claude-code-viewer-password";
  };
}
```
