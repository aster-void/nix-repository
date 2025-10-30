{
  system,
  fetchzip,
  stdenvNoCC,
  autoPatchelfHook,
  pkgs,
}: let
  platforms = {
    "x86_64-linux" = {
      url = "linux-x64";
      hash = "sha256-DZARH+bR5Rt/2esu9Cf/fHoxPl9xy4BXD1Vcwo3UIwM=";
    };
    "aarch-linux" = {
      url = "linux-arm64";
      hash = "";
    };
    "x86_64-darwin" = {
      url = "darwin-x64";
      hash = "";
    };
    "aarch-darwin" = {
      url = "darwin-arm64";
      hash = "";
    };
  };
  platform = platforms.${system};
in
  stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "lotion";
    version = "1.5.0";
    src = fetchzip {
      url = "https://github.com/puneetsl/lotion/releases/download/v${finalAttrs.version}/Lotion-${platform.url}-${finalAttrs.version}.zip";
      hash = platform.hash;
    };

    buildInputs = with pkgs; [
      libxcb
      vulkan-loader
      libx11
      libgcc
      libxrandr
      libxext
      cairo
      pango
      nss
      gtk3
      at-spi2-atk
      libgbm
      alsa-lib
    ];
    nativeBuildInputs = [
      autoPatchelfHook
    ];

    installPhase = ''
      mkdir -p $out $out/bin $out/vendor
      mv ./* $out/vendor
      ln -s ../vendor/lotion $out/bin/lotion
    '';
  })
