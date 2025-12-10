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
    rev = "4098bf848a010b52cd04dee2687307d2a4389da6";
    hash = "sha256-3zI5oc9nnyCW34Crj628PncGfw7f+DzdKmTHad+O2/Y=";
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
