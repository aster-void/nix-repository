{system}: let
  rev = "aec61ce88fa0d9d0e1c6f5ebef1e222e8b97180f";
  flake = builtins.getFlake "github:gj1118/helix/${rev}";
in
  flake.packages.${toString system}.default
