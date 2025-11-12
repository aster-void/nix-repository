# Fcitx5 Hazkey (v0.2.0)

The upstream project lives at <https://github.com/7ka-Hiira/fcitx5-hazkey>.

## Installation

> The installation method assumes you have already installed this flake. see [Installation Guide](./installation.md).

Zenzai model and llama libraries are pre-bundled.

### 1. Install the fcitx5 addon

```nix
{inputs, pkgs, ...}: {
    i18n.inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5.addons = [
            inputs.nix-repository.packages.${system}.fcitx5-hazkey
            # other addons...
        ];
    }
}
```

### 2. Install the hazkey server

```nix
{inputs, pkgs, ...}: {
    # As a NixOS Module
    imports = [ inputs.nix-repository.nixosModules.hazkey ];
    programs.hazkey.enable = true;

    # As a Home Manager Module
    imports = [ inputs.nix-repository.homeModules.hazkey ];
    programs.hazkey.enable = true;
}
```
