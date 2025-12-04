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
      self.homeModules.osgrep
      {
        programs.osgrep.enable = true;
        home.stateVersion = "24.05";
      }
    ];
    specialArgs = {inherit pkgs lib;};
  };

  # Extract the osgrep package from the module
  osgrepPackage = hmConfig.config.home.packages;
in
  pkgs.testers.nixosTest {
    name = "osgrep-module-test";

    nodes.machine = {
      # Install the package that the HM module provides
      environment.systemPackages = lib.flatten [osgrepPackage];
    };

    testScript = ''
      start_all()

      # Test that osgrep is available (tests the module installs the package)
      machine.succeed("which osgrep")

      # Test version flag
      machine.succeed("osgrep --version")

      # Test help flag
      machine.succeed("osgrep --help")
    '';
  }
