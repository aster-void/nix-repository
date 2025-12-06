{pkgs}:
pkgs.mkShell {
  packages = [
    pkgs.lefthook
    pkgs.nix-update
    pkgs.deno

    # formatter
    pkgs.alejandra
    pkgs.prettier
  ];
  shellHook = ''
    lefthook install
  '';
}
