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
    rev = "5d7dd76c5b24888929356b5614d8dbfbe3fb7470";
    hash = "sha256-Xqy69r5ebBvgfck6t46OyBKs42gP7E+rqtTqEqCj84A=";
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
