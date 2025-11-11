{system}: let
  rev = "b19a2d280b10aa8a9b9b8668b9a994df390404a5";
  flake = builtins.getFlake "github:gj1118/helix/${rev}";
in
  flake.packages.${toString system}.default
