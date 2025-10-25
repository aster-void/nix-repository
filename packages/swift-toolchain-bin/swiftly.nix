{
  stdenv,
  fetchzip,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "swiftly";
  version = "1.1.0";

  src = fetchzip {
    url = "http://download.swift.org/swiftly/linux/swiftly-${finalAttrs.version}-x86_64.tar.gz";
    hash = "sha256-JlUca1vCjaG6KqHJ05Bbj2cXOlMDv9Hd/5GNEax8ZDE=";
    stripRoot = false;
  };
  installPhase = ''
    mkdir -p $out/bin
    mv ./swiftly $out/bin/swiftly
  '';

  meta = {
    mainProgram = "swiftly";
  };
})
