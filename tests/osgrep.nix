{
  pkgs,
  lib,
  osgrep,
}:
pkgs.nixosTest {
  name = "osgrep-basic-test";

  nodes.machine = {
    environment.systemPackages = [osgrep];
  };

  testScript = ''
    start_all()

    # Test that osgrep is available
    machine.succeed("which osgrep")

    # Test version flag
    machine.succeed("osgrep --version")

    # Test help flag
    machine.succeed("osgrep --help")

    # Test that the binary executes without crashing
    machine.succeed("osgrep --help | grep -q 'osgrep'")
  '';
}
