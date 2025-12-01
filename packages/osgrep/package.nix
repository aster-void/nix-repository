{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs,
  pnpm,
  makeBinaryWrapper,
}: let
  version = "0.4.15";
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "osgrep";
    inherit version;
    dontUseCmakeConfigure = true;

    src = fetchFromGitHub {
      owner = "Ryandonofrio3";
      repo = "osgrep";
      rev = "v${version}";
      hash = "sha256-vMPeCK7FnL6ye9syLqDvA18+6loNC1i/PLMkuhJVIww=";
    };

    pnpmDeps = pnpm.fetchDeps {
      inherit (finalAttrs) pname version src;
      fetcherVersion = 2;
      hash = "sha256-XX+cD2ove73gHHoCaHzpk+iQ6JnQf3R8EnlT+cr6XYE=";
    };

    nativeBuildInputs = [
      nodejs
      pnpm
      pnpm.configHook
      makeBinaryWrapper
    ];

    buildPhase = ''
      runHook preBuild

      pnpm run build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      installRoot=$out/libexec/osgrep
      mkdir -p "$installRoot" $out/bin

      cp package.json pnpm-lock.yaml README.md LICENSE "$installRoot"
      cp -r dist node_modules "$installRoot"

      # drop bulky intermediate objects produced by node-gyp builds
      find "$installRoot/node_modules" -type d -name obj.target -prune -exec rm -rf {} +
      find "$installRoot/node_modules" -name '*.o' -delete

      makeWrapper ${lib.getExe nodejs} "$out/bin/osgrep" \
        --add-flags "$installRoot/dist/index.js" \
        --set NODE_ENV production

      runHook postInstall
    '';

    meta = with lib; {
      description = "Natural-language search that works like grep for AI agents and developers";
      homepage = "https://github.com/Ryandonofrio3/osgrep";
      license = licenses.asl20;
      maintainers = [];
      platforms = platforms.linux;
      mainProgram = "osgrep";
    };
  })
