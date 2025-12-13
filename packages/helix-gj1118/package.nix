{system}: let
  rev = "42e01a791af42b09f4efa8d189bbe1d6fef3e19b";
  flake = builtins.getFlake "github:gj1118/helix/${rev}";
in
  flake.packages.${toString system}.default
