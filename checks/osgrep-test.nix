{pkgs}: let
  osgrep = import ../packages/osgrep {inherit pkgs;};
in
  import ../tests/osgrep.nix {
    inherit pkgs osgrep;
    lib = pkgs.lib;
  }
