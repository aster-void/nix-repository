{pkgs, ...}: let
  llama = pkgs.callPackage ./llama.nix {};
  zenzai = pkgs.callPackage ./zenzai.nix {};
in
  pkgs.callPackage ./package.nix {
    llama = llama;
    zenzai = zenzai;
    passthru = {
      inherit llama zenzai;
    };
  }
