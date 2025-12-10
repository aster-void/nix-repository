{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs,
  pnpm,
  bun,
  makeBinaryWrapper,
}: let
  version = "0.9.4";
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "lsmcp";
    inherit version;

    src = fetchFromGitHub {
      owner = "mizchi";
      repo = "lsmcp";
      rev = "v${version}";
      hash = "sha256-paNzTqjB2gE2V1drt4srItUYNUzW/SQMnA9XoRYZ170=";
    };

    pnpmDeps = pnpm.fetchDeps {
      inherit (finalAttrs) pname version src;
      fetcherVersion = 2;
      hash = "sha256-09gx6IARzFlEG93nOHJWI0dLLZtNXww0K5wHqyvt5sQ=";
    };

    nativeBuildInputs = [
      nodejs
      pnpm
      pnpm.configHook
      bun
      makeBinaryWrapper
    ];

    pnpmInstallFlags = ["--ignore-scripts"];

    buildPhase = ''
      runHook preBuild

      bun build src/cli/lsmcp.ts --outfile build/lsmcp.js --target node --minify

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/lsmcp $out/bin

      cp build/lsmcp.js $out/share/lsmcp/app.js
      cp lsmcp.schema.json $out/share/lsmcp/

      makeWrapper ${lib.getExe nodejs} "$out/bin/lsmcp" \
        --add-flags "$out/share/lsmcp/app.js"

      runHook postInstall
    '';

    meta = with lib; {
      description = "Language Service Protocol MCP server";
      homepage = "https://github.com/mizchi/lsmcp";
      license = licenses.mit;
      maintainers = [];
      platforms = platforms.linux;
      mainProgram = "lsmcp";
    };
  })
