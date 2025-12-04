{
  lib,
  stdenv,
  fetchurl,
  nodejs,
  pnpm,
  bun,
  makeWrapper,
}: let
  version = "1.0.31";
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "context7-mcp";
    inherit version;

    # Fetch from npm registry instead of GitHub because:
    # - The npm package contains pre-built dist/index.js (TypeScript already compiled)
    # - Avoids needing to build from source in a pnpm monorepo setup
    src = fetchurl {
      url = "https://registry.npmjs.org/@upstash/context7-mcp/-/context7-mcp-${finalAttrs.version}.tgz";
      hash = "sha256-GW2uWkiIfEjzVuaDYZh4Son8BqXyHLtQgIzqBIek0Bc=";
    };

    # Use pnpm.fetchDeps instead of Bun for dependency fetching because:
    # - Bun's --frozen-lockfile flag is unreliable (doesn't fail when lockfile is missing)
    # - pnpm has better reproducibility guarantees with FOD (Fixed Output Derivation)
    # - The upstream project uses pnpm, so we match their tooling
    #
    # We include our own pnpm-lock.yaml in the repository because:
    # - The npm tarball doesn't include any lockfile
    # - This ensures deterministic dependency resolution across builds
    pnpmDeps = pnpm.fetchDeps {
      inherit (finalAttrs) pname version;
      # Create a source with both package.json from npm and our lockfile
      src = stdenv.mkDerivation {
        name = "context7-mcp-src-with-lock";
        inherit (finalAttrs) src;
        installPhase = ''
          tar xzf $src
          mkdir -p $out
          cp -r package/* $out/
          # Add our pre-generated pnpm-lock.yaml for reproducible builds
          cp ${./pnpm-lock.yaml} $out/pnpm-lock.yaml
        '';
      };
      fetcherVersion = 2;
      hash = "sha256-m+MxKn9spkBmU3dNpRdV9w2F29uJwIIZmkr/b7BG4RM=";
    };

    nativeBuildInputs = [
      nodejs
      pnpm.configHook
      bun # Used for bundling only, not for dependency management
      makeWrapper
    ];

    # Copy pnpm-lock.yaml into the main build source tree
    # (pnpm.configHook expects it to be present for --frozen-lockfile)
    postUnpack = ''
      cp ${./pnpm-lock.yaml} package/pnpm-lock.yaml
    '';

    pnpmInstallFlags = ["--ignore-scripts"];

    buildPhase = ''
      runHook preBuild

      # Bundle the application with Bun
      # We use bundling instead of compiling because bun's --compile flag
      # has issues with argument parsing (shows Bun's help instead of app help)
      bun build dist/index.js --outfile build/index.js --target bun --minify

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/context7-mcp $out/bin

      cp build/index.js $out/share/context7-mcp/app.js
      # Create a wrapper that calls 'bun <bundled-js>'
      # This approach ensures proper argument handling and matches ccusage-codex
      makeWrapper ${lib.getExe bun} $out/bin/context7-mcp \
        --add-flags "$out/share/context7-mcp/app.js"

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
