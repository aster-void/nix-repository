{
  stdenv,
  nodejs,
  fetchFromGitHub,
  pnpm,
  makeBinaryWrapper,
  lib,
  bun,
}: let
  version = "17.1.8";
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "ccusage-mcp";
    inherit version;

    src = fetchFromGitHub {
      owner = "ryoppippi";
      repo = "ccusage";
      tag = "v${version}";
      hash = "sha256-FFf3jHvsf+fwaTUxPNuiQ9pcKznwp6Ps5nXqQEXpj5Y=";
    };

    pnpmDeps = pnpm.fetchDeps {
      inherit (finalAttrs) pname version src;
      fetcherVersion = 2;
      hash = "sha256-gzbFBw49KManquZenI2/3QkwHCOJWx7ivqNe58GQdg8=";
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

      bun build apps/mcp/src/index.ts --outfile build/index.js --target bun --minify

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out $out/bin $out/share/ccusage-mcp

      cp ./build/index.js $out/share/ccusage-mcp/app.js
      makeWrapper ${lib.getExe bun} $out/bin/ccusage-mcp --add-flags "$out/share/ccusage-mcp/app.js"

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
