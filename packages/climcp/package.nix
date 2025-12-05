{
  lib,
  stdenv,
  fetchurl,
  bun,
  makeWrapper,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "climcp";
  version = "0.0.1";

  # Fetch from npm registry - contains pre-built bundled index.js
  src = fetchurl {
    url = "https://registry.npmjs.org/climcp/-/climcp-${finalAttrs.version}.tgz";
    hash = "sha256-yKXBGQS69MFASGt5Dnzf5EWgoMiTkNy5WMUC5WKLOpc=";
  };

  nativeBuildInputs = [makeWrapper];

  # npm tarball extracts to "package/" directory
  sourceRoot = "package";

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/climcp $out/bin

    cp index.js $out/share/climcp/
    makeWrapper ${lib.getExe bun} $out/bin/climcp \
      --add-flags "$out/share/climcp/index.js"

    runHook postInstall
  '';

  meta = {
    description = "An interface between you and MCP servers";
    homepage = "https://github.com/aster-void/climcp";
    license = lib.licenses.mit;
    maintainers = [];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "climcp";
  };
})
