{
  pkgs,
  lib,
  gwq,
}:
pkgs.nixosTest {
  name = "gwq-basic-test";

  nodes.machine = {
    environment.systemPackages = [gwq];
  };

  testScript = ''
    start_all()

    # Test that gwq is available
    machine.succeed("which gwq")

    # Test version flag
    machine.succeed("gwq --version")

    # Test help flag
    machine.succeed("gwq --help")

    # Test that the binary executes without crashing
    machine.succeed("gwq --help | grep -q 'gwq'")
  '';
}
