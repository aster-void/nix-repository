{pkgs, ...}: let
  llama-cpu = pkgs.callPackage ./llama.nix {};
  llama-vulkan = pkgs.callPackage ./llama-vulkan.nix {};
  zenzai = pkgs.callPackage ./zenzai.nix {};
in
  pkgs.callPackage ./package.nix {
    llama = llama-cpu;
    zenzai = zenzai;
    passthru = {
      inherit llama-cpu llama-vulkan zenzai;
    };
  }
