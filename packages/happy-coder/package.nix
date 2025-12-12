{
  lib,
  yarn2nix-moretea,
  fetchFromGitHub,
  nodejs,
}: let
  version = "0.12.0";
  src = fetchFromGitHub {
    owner = "slopus";
    repo = "happy-cli";
    tag = "v${version}";
    hash = "sha256-Y7BxCr9QuMOQOudUO64W50Ud+J4+95mENlmWYiEbVAQ=";
  };
in
  yarn2nix-moretea.mkYarnPackage {
    pname = "happy-coder";
    inherit version src;

    packageJSON = "${src}/package.json";
    yarnLock = "${src}/yarn.lock";

    # Requires Node.js >= 20.0.0
    buildInputs = [nodejs];

    buildPhase = ''
      runHook preBuild
      yarn --offline build
      runHook postBuild
    '';

    meta = {
      description = "Code on the go controlling claude code from your mobile device";
      homepage = "https://github.com/slopus/happy-cli";
      license = lib.licenses.mit;
      maintainers = [];
      mainProgram = "happy";
    };
  }
