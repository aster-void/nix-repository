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
            inputs.nix-repository.packages.${pkgs.system}.fcitx5-hazkey
            # other addons...
        ];
    }
}
```

### 2. Install the hazkey server

```nix
{inputs, pkgs, ...}: {
    # For both NixOS and Home Manager
    imports = [ inputs.nix-repository.nixosModules.hazkey ]; # or homeModules.hazkey
    services.hazkey.enable = true;
}
```

> **Note:** `programs.hazkey` is deprecated in favor of `services.hazkey`. Using `programs.hazkey` will still work but will show a deprecation warning.

## llama.cpp Backend Selection

By default, fcitx5-hazkey uses the CPU backend for llama.cpp. You can switch to the Vulkan backend for GPU acceleration.

```nix
{inputs, pkgs, ...}: let
  fcitx5-hazkey = inputs.nix-repository.packages.${pkgs.system}.fcitx5-hazkey;
in {
    # CPU Backend (Default)
    services.hazkey.enable = true;

    # Vulkan Backend - GPU-accelerated, requires Vulkan-capable GPU and drivers
    services.hazkey = {
        enable = true;
        package = fcitx5-hazkey.override { llama = fcitx5-hazkey.llama-vulkan; };
    };
}
```
