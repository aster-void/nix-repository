# JavaScript Packaging Examples

## npm (buildNpmPackage)

Best for simple npm projects with standard build scripts.

```nix
# packages/my-npm-app/package.nix
{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage rec {
  pname = "my-npm-app";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "owner";
    repo = "my-npm-app";
    tag = "v${version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  npmDepsHash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";

  # Optional: skip native addon downloads
  env.PUPPETEER_SKIP_DOWNLOAD = "true";

  buildPhase = ''
    runHook preBuild
    npm run build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/node_modules/${pname} $out/bin
    cp -r dist package.json $out/lib/node_modules/${pname}/
    ln -s $out/lib/node_modules/${pname}/dist/index.js $out/bin/${pname}
    runHook postInstall
  '';

  meta = {
    description = "Short description";
    homepage = "https://github.com/owner/my-npm-app";
    license = lib.licenses.mit;
    maintainers = [];
    mainProgram = "my-npm-app";
  };
}
```

## pnpm (stdenv + pnpm.fetchDeps)

Best for pnpm-based projects or when more control is needed.

```nix
# packages/my-pnpm-app/package.nix
{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs,
  pnpm,
  makeBinaryWrapper,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "my-pnpm-app";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "owner";
    repo = "my-pnpm-app";
    rev = "v${finalAttrs.version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  pnpmDeps = pnpm.fetchDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";
  };

  nativeBuildInputs = [
    nodejs
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

    mkdir -p $out/libexec/${finalAttrs.pname} $out/bin
    cp -r dist node_modules package.json $out/libexec/${finalAttrs.pname}/

    makeWrapper ${lib.getExe nodejs} $out/bin/${finalAttrs.pname} \
      --add-flags "$out/libexec/${finalAttrs.pname}/dist/index.js"

    runHook postInstall
  '';

  meta = {
    description = "Short description";
    homepage = "https://github.com/owner/my-pnpm-app";
    license = lib.licenses.mit;
    maintainers = [];
    mainProgram = "my-pnpm-app";
  };
})
```

## bun (pnpm deps + bun build)

Best for TypeScript projects that can be bundled into a single file.

```nix
# packages/my-bun-app/package.nix
{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs,
  pnpm,
  bun,
  makeBinaryWrapper,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "my-bun-app";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "owner";
    repo = "my-bun-app";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  pnpmDeps = pnpm.fetchDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";
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
    bun build ./src/index.ts --outfile build/index.js --target bun --minify
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/${finalAttrs.pname} $out/bin
    cp build/index.js $out/share/${finalAttrs.pname}/app.js

    makeWrapper ${lib.getExe bun} $out/bin/${finalAttrs.pname} \
      --add-flags "$out/share/${finalAttrs.pname}/app.js"

    runHook postInstall
  '';

  meta = {
    description = "Short description";
    homepage = "https://github.com/owner/my-bun-app";
    license = lib.licenses.mit;
    maintainers = [];
    mainProgram = "my-bun-app";
  };
})
```

## Comparison

| Method            | Use Case                        | Pros                                    | Cons                 |
| ----------------- | ------------------------------- | --------------------------------------- | -------------------- |
| `buildNpmPackage` | Standard npm projects           | Simple, official                        | Less flexible        |
| pnpm + stdenv     | pnpm projects, complex builds   | Full control, works with pnpm lockfiles | More verbose         |
| bun build         | TypeScript, single-file bundles | Fast builds, small output               | Requires bun runtime |

## Getting Hashes

1. Set hashes to placeholder:

   ```nix
   hash = lib.fakeHash;
   npmDepsHash = lib.fakeHash;  # or pnpmDeps hash
   ```

2. Run `nix build .#my-app` and copy the correct hashes from error messages.

## Real Examples

- npm: [packages/chrome-devtools-mcp/package.nix](../packages/chrome-devtools-mcp/package.nix)
- pnpm: [packages/osgrep/package.nix](../packages/osgrep/package.nix)
- bun: [packages/ccusage/package.nix](../packages/ccusage/package.nix)
