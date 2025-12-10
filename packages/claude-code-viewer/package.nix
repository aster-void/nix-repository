{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs,
  pnpm,
  makeBinaryWrapper,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "claude-code-viewer";
  version = "0.4.13";

  src = fetchFromGitHub {
    owner = "d-kimuson";
    repo = "claude-code-viewer";
    rev = "v${finalAttrs.version}";
    hash = "sha256-i2CwTyO4uf7HZH9G704E5pcCdZpLQdPQlkB+zJUZ59c=";
  };

  pnpmDeps = pnpm.fetchDeps {
    inherit (finalAttrs) pname version src;
    # Run `nix build .#claude-code-viewer` to get the correct hash
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm
    pnpm.configHook
    makeBinaryWrapper
  ];

  buildPhase = ''
    runHook preBuild

    pnpm lingui:compile
    pnpm build:frontend
    pnpm build:backend

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    installRoot=$out/libexec/claude-code-viewer
    mkdir -p "$installRoot" $out/bin

    cp package.json pnpm-lock.yaml "$installRoot"
    cp -r dist node_modules "$installRoot"

    # drop bulky intermediate objects produced by node-gyp builds
    find "$installRoot/node_modules" -type d -name obj.target -prune -exec rm -rf {} +
    find "$installRoot/node_modules" -name '*.o' -delete

    makeWrapper ${lib.getExe nodejs} "$out/bin/claude-code-viewer" \
      --add-flags "$installRoot/dist/main.js" \
      --set NODE_ENV production

    runHook postInstall
  '';

  meta = with lib; {
    description = "A full-featured web-based Claude Code client for managing projects";
    homepage = "https://github.com/d-kimuson/claude-code-viewer";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.unix;
    mainProgram = "claude-code-viewer";
  };
})
