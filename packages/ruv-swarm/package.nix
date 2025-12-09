{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
}:
rustPlatform.buildRustPackage rec {
  pname = "ruv-swarm";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "ruvnet";
    repo = "ruv-FANN";
    rev = "f0f837f0d22ca1dc09f058d0270c60c9bc07fad3";
    hash = "sha256-AA09Osu0ndTSLiyQae1IVII82twMttIMBksKZe7RwmI=";
  };

  sourceRoot = "${src.name}/ruv-swarm";

  cargoHash = "sha256-uqcvD1HyZr7FXVsvhkywrKLqIk97NkoeVAqjG+GwiEQ=";

  cargoBuildFlags = ["-p" "ruv-swarm-cli"];
  cargoTestFlags = ["-p" "ruv-swarm-cli"];

  nativeBuildInputs = [pkg-config];
  buildInputs = [openssl];

  doCheck = false;

  meta = {
    description = "Distributed swarm orchestration CLI with cognitive diversity";
    longDescription = ''
      ruv-swarm is a lightweight neural network orchestration system built in Rust.
      It instantly deploys purpose-built "brains" specialized for specific tasks.
    '';
    homepage = "https://github.com/ruvnet/ruv-FANN";
    license = with lib.licenses; [mit asl20];
    maintainers = [];
    mainProgram = "ruv-swarm";
  };
}
