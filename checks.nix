{
  self,
  inputs,
  lib,
  ...
}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    checks = {
      osgrep-test = import ./tests/osgrep.nix {
        inherit pkgs lib;
        osgrep = self.packages.${system}.osgrep;
      };

      gwq-test = import ./tests/gwq.nix {
        inherit pkgs lib;
        gwq = self.packages.${system}.gwq;
      };
    };
  };
}
