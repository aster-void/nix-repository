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
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "zz";
  version = "0-unstable-${lib.substring 0 7 finalAttrs.src.rev}";

  src = fetchFromGitHub {
    owner = "aster-void";
    repo = "zz";
    rev = "329f9ee23326c089e07c5a39535e2542e366e039";
    hash = "sha256-SubzlNEzWvveGzNAzBiFHr3Wxle2M4W/J/BdH9fkTko=";
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
})
