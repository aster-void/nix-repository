{
  stdenv,
  nodejs,
  fetchFromGitHub,
  pnpm,
  bun,
  makeBinaryWrapper,
  lib,
}: let
  version = "17.1.6";
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "ccusage";
    inherit version;

    src = fetchFromGitHub {
      owner = "ryoppippi";
      repo = "ccusage";
      tag = "v${version}";
      hash = "sha256-aC7AYaTTLzYHhPP9sttcNxqVDFf/WjFq8pFF7UTslJ0=";
    };

    pnpmDeps = pnpm.fetchDeps {
      inherit (finalAttrs) pname version src;
      fetcherVersion = 2;
      hash = "sha256-WXHDcYtDSGcAscXJg8sXLT5miqjIndNcF8Z6RZUluy8=";
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

      bun build ./apps/ccusage/src/index.ts --outfile build/index.js --target bun --minify

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out $out/share/ccusage $out/bin

      cp build/index.js $out/share/ccusage/app.js
      makeWrapper ${lib.getExe bun} $out/bin/ccusage --add-flags "$out/share/ccusage/app.js"

      runHook postInstall
    '';

    meta = with lib; {
      description = "CLI tool for analyzing Claude Code usage from local JSONL files";
      homepage = "https://www.npmjs.com/package/ccusage";
      license = licenses.mit;
      maintainers = [];
      platforms = platforms.all;
      mainProgram = "ccusage";
    };
  })
