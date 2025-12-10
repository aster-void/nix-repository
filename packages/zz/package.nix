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
    rev = "2db65e9c91aa4ce2e753a5894f947eef1bea88e5";
    hash = "sha256-qH4q/833N+K5z6JPCatoTDKwQ4MLtu3Jqz1e2kbgwdg=";
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
