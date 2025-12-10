{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs,
  pnpm,
  jq,
  makeBinaryWrapper,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "claude-code-viewer";
  version = "0.4.13";

  src = fetchFromGitHub {
    owner = "d-kimuson";
    repo = "claude-code-viewer";
    rev = "v${finalAttrs.version}";
    hash = "sha256-xDEDrmQJXoru+/oPQuHXBBvS9/iFCq6f9mbacWCpchQ=";
  };

  # Remove packageManager field to prevent pnpm from trying to switch versions via corepack
  postPatch = ''
    ${lib.getExe jq} 'del(.packageManager)' package.json > package.json.tmp
    mv package.json.tmp package.json
  '';

  pnpmDeps = pnpm.fetchDeps {
    inherit (finalAttrs) pname version src postPatch;
    fetcherVersion = 2;
    hash = "sha256-fYOQCpsxEiWHNEcYzpfg12Tz2UUF4YfCVmffTdJ0Ky4=";
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
