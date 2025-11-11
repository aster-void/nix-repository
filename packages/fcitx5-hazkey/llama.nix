{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  ...
}: let
  version = "20251109.0";
in
  stdenv.mkDerivation {
    pname = "hazkey-llama";
    inherit version;

    src = fetchzip {
      url = "https://github.com/7ka-Hiira/llama.cpp/releases/download/v${version}/llama-linux-x86_64-cpu-v${version}.tar.gz";
      hash = "sha256-Hw96OYrd3LoePFhNk3Whk90I0pREx2gpxanIMxo+bHs=";
      stripRoot = false;
    };

    nativeBuildInputs = [
      autoPatchelfHook
    ];

    buildInputs = [
      stdenv.cc.cc.lib
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
      description = "Llama.cpp libraries for hazkey (CPU version)";
      license = licenses.mit;
      maintainers = [];
      platforms = ["x86_64-linux"];
    };
  }
