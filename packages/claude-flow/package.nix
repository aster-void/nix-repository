{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs,
  python3,
  makeBinaryWrapper,
}:
buildNpmPackage {
  pname = "claude-flow";
  version = "2.7.34";

  src = fetchFromGitHub {
    owner = "ruvnet";
    repo = "claude-flow";
    tag = "v2.7.34";
    hash = "sha256-20dMNAihqY6oiBjDUKHj/IlGn9gVyQOOGbVlIrWksv0=";
  };

  npmDepsHash = "sha256-AWizQ6AE1066acYshQTGrAmHIqxzgEHLzr96zLyVC7w=";

  makeCacheWritable = true;
  npmFlags = ["--legacy-peer-deps"];

  nativeBuildInputs = [
    makeBinaryWrapper
    python3
  ];

  dontNpmInstall = true;
  npmRebuildFlags = ["--ignore-scripts"];

  buildPhase = ''
    runHook preBuild
    npm run clean
    npm run build:esm
    npm run build:cjs
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/claude-flow $out/bin

    cp -r dist dist-cjs node_modules package.json bin $out/share/claude-flow/

    makeWrapper ${lib.getExe nodejs} $out/bin/claude-flow \
      --add-flags "$out/share/claude-flow/dist/src/cli/main.js" \
      --set NODE_ENV production \
      --chdir "$out/share/claude-flow"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Enterprise-grade AI agent orchestration platform for Claude";
    homepage = "https://github.com/ruvnet/claude-flow";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.linux;
    mainProgram = "claude-flow";
  };
}
