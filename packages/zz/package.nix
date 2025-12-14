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
  version = "${lib.substring 0 7 finalAttrs.src.rev}";

  src = fetchFromGitHub {
    owner = "aster-void";
    repo = "zz";
    rev = "8c5df43a3e60364c521a56fe77f8ba81c7282fce";
    hash = "sha256-tE42mFLX+xv80Dpb7czerDb6TW5+C9x9Qkjfw78NLrs=";
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
