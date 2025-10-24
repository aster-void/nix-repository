{pkgs}:
pkgs.mkShell {
  packages = [
    pkgs.alejandra
    pkgs.lefthook
  ];
  shellHook = ''
    lefthook install
  '';
}
