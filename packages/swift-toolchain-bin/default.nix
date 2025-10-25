{pkgs}: let
  swiftly = pkgs.callPackage ./swiftly.nix {};
  fetchSwiftToolchain = pkgs.callPackage ./fetchSwiftToolchain.nix {inherit swiftly;};
in
  pkgs.callPackage ./package.nix {
    inherit fetchSwiftToolchain;
  }
  // {
    inherit swiftly fetchSwiftToolchain;
    swiftToolchain = fetchSwiftToolchain {
      version = "6.2.0";
      hash = "sha256-x353ynPDD3cr9uG4/iAX/v5g8RN80NL2psRgeFiNg+Y=";
    };
  }
