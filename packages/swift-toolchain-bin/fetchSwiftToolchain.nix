{
  stdenvNoCC,
  swiftly,
}: {
  version,
  hash ? "",
}:
stdenvNoCC.mkDerivation {
  pname = "swift-toolchain-src";
  inherit version;

  nativeBuildInputs = [
    swiftly
  ];

  dontUnpack = true;
  installPhase = ''
    export SWIFTLY_HOME_DIR=$out/share/swiftly;
    export SWIFTLY_BIN_DIR=$out/share/swiftly/bin;
    export SWIFTLY_TOOLCHAINS_DIR=$out/share/swiftly/toolchains;

    echo '[SWIFTLY BEFORE INSTALL OUT]'
    swiftly init --skip-install --platform fedora39 --no-modify-profile || true
    swiftly install ${version} --assume-yes --no-verify || true
  '';

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  outputHash = hash;
}
