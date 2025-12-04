{
  pkgs,
  self,
  system ? pkgs.system,
  ...
}: let
  lib = pkgs.lib;

  # Evaluate the Home Manager module to get the package it provides
  hmConfig = lib.evalModules {
    modules = [
      self.homeModules.gwq
      {
        programs.gwq.enable = true;
        home.stateVersion = "24.05";
      }
    ];
    specialArgs = {inherit pkgs lib;};
  };

  # Extract the gwq package from the module
  gwqPackage = hmConfig.config.home.packages;
in
  pkgs.testers.nixosTest {
    name = "gwq-module-test";

    nodes.machine = {
      # Install the package that the HM module provides
      environment.systemPackages = lib.flatten [gwqPackage];
    };

    testScript = ''
      start_all()

      # Test that gwq is available (tests the module installs the package)
      machine.succeed("which gwq")

      # Test version flag
      machine.succeed("gwq --version")

      # Test help flag
      machine.succeed("gwq --help")
    '';
  }
