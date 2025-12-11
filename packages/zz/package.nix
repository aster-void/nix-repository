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
    rev = "3277207d690dab6f9f1be41e8566490f65918aea";
    hash = "sha256-jUp0+el0AqsiyrrJXnAIafd0YQ2ydNwwWYPXVOocOpY=";
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
