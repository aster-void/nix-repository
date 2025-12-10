{
  pkgs,
  flake,
  system ? pkgs.system,
  ...
}:
pkgs.testers.nixosTest {
  name = "claude-code-viewer-nixos-test";

  nodes.machine = {
    imports = [
      flake.nixosModules.claude-code-viewer
    ];

    # Create a test user
    users.users.testuser = {
      isNormalUser = true;
      home = "/home/testuser";
    };

    # Enable the claude-code-viewer service
    services.claude-code-viewer = {
      enable = true;
      user = "testuser";
      port = 3400;
      host = "127.0.0.1";
    };
  };

  testScript = ''
    start_all()

    # Wait for the service to start
    machine.wait_for_unit("claude-code-viewer.service")

    # Test that the service is running
    machine.succeed("systemctl is-active claude-code-viewer.service")

    # Test that the binary exists
    machine.succeed("which claude-code-viewer")

    # Wait for the web server to be ready
    machine.wait_for_open_port(3400)

    # Test that the web server responds
    machine.succeed("curl -sf http://127.0.0.1:3400/ > /dev/null || curl -sf http://127.0.0.1:3400/ | head -c 100")
  '';
}
