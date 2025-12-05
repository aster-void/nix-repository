{system}: let
  rev = "ebff6b73a7a652dbfab66d533d3acee0a98024ed";
  flake = builtins.getFlake "github:gj1118/helix/${rev}";
in
  flake.packages.${toString system}.default
