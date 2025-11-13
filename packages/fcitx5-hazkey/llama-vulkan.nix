{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  vulkan-loader,
  ...
}: let
  version = "20251109.0";
in
  stdenv.mkDerivation {
    pname = "hazkey-llama-vulkan";
    inherit version;

    src = fetchzip {
      url = "https://github.com/7ka-Hiira/llama.cpp/releases/download/v${version}/llama-linux-x86_64-vulkan-v${version}.tar.gz";
      hash = "sha256-C0J5IYyKvr4MX4PU0fMu5WNnOWr2EvijdJmpGjgC3nQ=";
      stripRoot = false;
    };

    nativeBuildInputs = [
      autoPatchelfHook
    ];

    buildInputs = [
      stdenv.cc.cc.lib
      vulkan-loader
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib/hazkey/llama
      cp -r lib/* $out/lib/hazkey/llama/ 2>/dev/null || true
      cp *.so* $out/lib/hazkey/llama/ 2>/dev/null || true

      runHook postInstall
    '';

    meta = with lib; {
      homepage = "https://github.com/7ka-Hiira/llama.cpp";
      description = "Llama.cpp libraries for hazkey (Vulkan version)";
      license = licenses.mit;
      maintainers = [];
      platforms = ["x86_64-linux"];
    };
  }
