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
    rev = "c6b88a1d7712e5754569fde47671dbadc5897697";
    hash = "sha256-UMHFOEUEffrTDzeSz5TBIW2MpQ8VMuEJ6qWFQQLaEdM=";
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
