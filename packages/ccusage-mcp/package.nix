{
  stdenv,
  nodejs,
  fetchFromGitHub,
  pnpm,
  makeBinaryWrapper,
  lib,
  bun,
}: let
  version = "17.1.4";
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "ccusage-mcp";
    inherit version;

    src = fetchFromGitHub {
      owner = "ryoppippi";
      repo = "ccusage";
      tag = "v${version}";
      hash = "sha256-mSuTSi8YCRQrjXSAPijDkiCO3qRbmjvQ8/jxs6DQGro=";
    };

    pnpmDeps = pnpm.fetchDeps {
      inherit (finalAttrs) pname version src;
      fetcherVersion = 2;
      hash = "sha256-gIuFqZnmZ1eOGHJdFWdKtdb9zuU5Oe0Eq5LVG5NKsk8=";
    };

    nativeBuildInputs = [
      nodejs
      pnpm.configHook
      bun
      makeBinaryWrapper
    ];
    pnpmInstallFlags = ["--ignore-scripts"];

    buildPhase = ''
      runHook preBuild

      bun build apps/mcp/src/index.ts --outfile build/index.js --target bun

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out $out/bin $out/share/ccusage-mcp

      cp ./build/index.js $out/share/ccusage-mcp/app.js
      makeWrapper ${lib.getExe nodejs} $out/bin/ccusage-mcp --add-flags "$out/share/ccusage-mcp/app.js"

      runHook postInstall
    '';

    meta = with lib; {
      description = "Model Context Protocol server that exposes ccusage data to Claude Desktop and other MCP-compatible tools";
      homepage = "https://www.npmjs.com/package/@ccusage/mcp";
      license = licenses.mit;
      maintainers = [];
      platforms = platforms.all;
      mainProgram = "ccusage-mcp";
    };
  })
