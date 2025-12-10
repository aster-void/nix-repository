{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  ghq,
  fzf,
  zellij,
  ripgrep,
}:
stdenvNoCC.mkDerivation {
  pname = "zz";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "aster-void";
    repo = "zz";
    rev = "b2bfacd6cb05cc0b74d19877d19d76f58c02317d";
    hash = "sha256-uNY8EV0BgvW4muvnYrA4He0zA7eFM8K+MF6SUxIxwwo=";
  };

  nativeBuildInputs = [makeWrapper];

  installPhase = ''
    runHook preInstall
    install -Dm755 zz.sh $out/bin/zz
    wrapProgram $out/bin/zz \
      --prefix PATH : ${lib.makeBinPath [ghq fzf zellij ripgrep]}
    runHook postInstall
  '';

  meta = {
    description = "Fuzzy-find ghq repo and attach/create zellij session";
    homepage = "https://github.com/aster-void/zz";
    license = lib.licenses.unlicense;
    maintainers = [];
    mainProgram = "zz";
  };
}
