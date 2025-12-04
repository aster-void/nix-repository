{pkgs}: let
  gwq = import ../packages/gwq {inherit pkgs;};
in
  import ../tests/gwq.nix {
    inherit pkgs gwq;
    lib = pkgs.lib;
  }
