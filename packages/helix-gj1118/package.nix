{system}: let
  rev = "a32e07e243ae0119ddfa374b551ee7f546f68d8f";
  flake = builtins.getFlake "github:gj1118/helix/${rev}";
in
  flake.packages.${toString system}.default
