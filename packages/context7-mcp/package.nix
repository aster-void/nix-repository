{
  lib,
  stdenvNoCC,
  fetchurl,
  bun,
  makeWrapper,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "context7-mcp";
  version = "1.0.31";

  src = fetchurl {
    url = "https://registry.npmjs.org/@upstash/context7-mcp/-/context7-mcp-${finalAttrs.version}.tgz";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # TODO: update hash
  };

  # FOD for fetching Bun dependencies
  bunDeps = stdenvNoCC.mkDerivation {
    pname = "${finalAttrs.pname}-deps";
    inherit (finalAttrs) version src;

    nativeBuildInputs = [bun];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild

      export HOME=$TMPDIR
      bun install --frozen-lockfile --no-progress

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r node_modules $out/

      runHook postInstall
    '';

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # TODO: update hash
  };

  nativeBuildInputs = [
    bun
    makeWrapper
  ];

  unpackPhase = ''
    runHook preUnpack

    tar xzf $src
    cd package

    runHook postUnpack
  '';

  buildPhase = ''
    runHook preBuild

    export HOME=$TMPDIR
    ln -s ${finalAttrs.bunDeps}/node_modules node_modules

    # Compile to standalone executable
    bun build node_modules/.bin/context7-mcp \
      --target=bun \
      --compile \
      --outfile=context7-mcp

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -Dm755 context7-mcp $out/bin/context7-mcp

    runHook postInstall
  '';

  meta = {
    description = "Context7 MCP Server - Up-to-date code documentation for LLMs and AI code editors";
    homepage = "https://github.com/upstash/context7";
    license = lib.licenses.mit;
    maintainers = [];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "context7-mcp";
  };
})
