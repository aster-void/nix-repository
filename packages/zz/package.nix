{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  ghq,
  fzf,
  zellij,
  ripgrep,
  zoxide,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "zz";
  version = "${lib.substring 0 7 finalAttrs.src.rev}";

  src = fetchFromGitHub {
    owner = "aster-void";
    repo = "zz";
    rev = "e1884ad1fc9d3d6d3727a44a818a21a1749d87f6";
    hash = "sha256-WSprSMyHIkJuodUBjmpblPTfAccNsXuTtcU9FYAIGAk=";
  };

  nativeBuildInputs = [makeWrapper];

  installPhase = ''
    runHook preInstall
    install -Dm755 zz.sh $out/bin/zz
    wrapProgram $out/bin/zz \
      --prefix PATH : ${lib.makeBinPath [ghq fzf zellij ripgrep zoxide]}
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
