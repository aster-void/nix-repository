{
  inputs,
  pkgs,
}:
inputs.rollcron.packages.${pkgs.stdenv.hostPlatform.system}.default
