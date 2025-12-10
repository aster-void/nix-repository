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
    rev = "99e9de24ef08ec1c0278f780bb46c820a323547a";
    hash = "sha256-Xb8gGwggHuvo8oRHUj9YOQ5tMjBAlP1hboCpurozDqc=";
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
