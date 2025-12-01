{system}: let
  rev = "71072f8abd84c6b20f960ce141e31e3744c2004d";
  flake = builtins.getFlake "github:gj1118/helix/${rev}";
in
  flake.packages.${toString system}.default
