{
  pkgs,
  stdenv,
  autoPatchelfHook,
  fetchSwiftToolchain,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "swift-toolchain";
  version = "6.2.0";
  buildInputs = with pkgs; [
    stdenv.cc.cc.lib
    libgcc
    libuuid
    libz
    libxml2_13
    curl
    libedit
    # libtinfo
    libpanel
    python312
    sqlite
  ];
  nativeBuildInputs = [
    autoPatchelfHook
  ];
  src = fetchSwiftToolchain {
    version = "6.2.0";
    hash = "sha256-x353ynPDD3cr9uG4/iAX/v5g8RN80NL2psRgeFiNg+Y=";
  };

  installPhase = ''
    mkdir -p $out
    cp -r share/swiftly/toolchains/${finalAttrs.version}/usr/* $out
  '';
})
