{system}: let
  rev = "175f2ef43bb7209c656830c1f2d007056d4e9be6";
  flake = builtins.getFlake "github:gj1118/helix/${rev}";
in
  flake.packages.${toString system}.default
