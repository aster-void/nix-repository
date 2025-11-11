{
  lib,
  stdenv,
  fetchurl,
  ...
}: let
  version = "3.1";
in
  stdenv.mkDerivation {
    pname = "hazkey-zenzai";
    inherit version;

    src = fetchurl {
      url = "https://huggingface.co/Miwa-Keita/zenz-v${version}-small-gguf/resolve/main/ggml-model-Q5_K_M.gguf";
      hash = "sha256-TekwwGvvjCY6oapAaEryBttM4bljdbO47Q6lCOCxT2w=";
    };

    dontUnpack = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/hazkey
      cp $src $out/share/hazkey/zenzai.gguf

      runHook postInstall
    '';

    meta = with lib; {
      homepage = "https://huggingface.co/Miwa-Keita/zenz-v3.1-small-gguf";
      description = "Zenzai v3.1 model for fcitx5-hazkey (Q5_K_M quantization, 73.9MB)";
      license = licenses.mit;
      maintainers = [];
      platforms = platforms.all;
    };
  }
