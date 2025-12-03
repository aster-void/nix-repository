{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs,
  pnpm,
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
      makeBinaryWrapper
    ];

    pnpmInstallFlags = ["--ignore-scripts"];

    buildPhase = ''
      runHook preBuild

      pnpm run build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      installRoot=$out/libexec/lsmcp
      mkdir -p "$installRoot" $out/bin

      cp package.json pnpm-lock.yaml README.md LICENSE lsmcp.schema.json "$installRoot"
      cp -r dist node_modules "$installRoot"

      makeWrapper ${lib.getExe nodejs} "$out/bin/lsmcp" \
        --add-flags "$installRoot/dist/lsmcp.js" \
        --set NODE_ENV production

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
