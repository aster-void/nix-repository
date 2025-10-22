{pkgs, ...}: let
  version = "0.10.7";
  cargo-compete = pkgs.rustPlatform.buildRustPackage {
    pname = "cargo-compete";
    inherit version;

    buildInputs = with pkgs; [
      openssl
    ];
    nativeBuildInputs = with pkgs; [
      pkg-config
    ];

    src = pkgs.fetchzip {
      url = "https://github.com/qryxip/cargo-compete/archive/refs/tags/v${version}.tar.gz";
      hash = "sha256-qlRVHSUVOqdTx4H3pE19Fy634742veTisHm6IqfKBUQ=";
    };

    cargoHash = "sha256-lid1tyR8Y6lvjpeGJ4vGzqDTY6V2y/5rL9fGyjyF3yw=";
    doCheck = false; # this requires network access
  };
in
  cargo-compete
