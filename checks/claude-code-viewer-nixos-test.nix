{
  pkgs,
  flake,
  ...
}:
pkgs.testers.nixosTest {
  name = "claude-code-viewer-nixos-test";

  nodes.local = {
    imports = [
      flake.nixosModules.claude-code-viewer
    ];

    users.users.testuser = {
      isNormalUser = true;
      home = "/home/testuser";
    };

    services.claude-code-viewer = {
      enable = true;
      user = "testuser";
      port = 3400;
      host = "127.0.0.1";
    };
  };

  nodes.server = {
    imports = [
      flake.nixosModules.claude-code-viewer
    ];

    users.users.testuser = {
      isNormalUser = true;
      home = "/home/testuser";
    };

    environment.etc."claude-code-viewer-password".text = "testpassword123";

    services.claude-code-viewer = {
      enable = true;
      user = "testuser";
      port = 3400;
      host = "0.0.0.0";
      openFirewall = true;
      passwordFile = "/etc/claude-code-viewer-password";
    };
  };

  # Test coverage:
  #
  #   From    → To      Endpoint  Auth    Expected
  #   ──────────────────────────────────────────────
  #   local   → local   /         -       ✅ PASS
  #   local   → server  /         -       ✅ PASS
  #   local   → server  /api      none    🔒 401
  #   local   → server  /api      auth    ✅ PASS
  #   server  → server  /         -       ✅ PASS
  #   server  → server  /api      none    🔒 401
  #   server  → server  /api      auth    ✅ PASS
  #   server  → local   /         -       🚫 BLOCK
  #
  # Session token: base64("ccv-session:testpassword123")
  testScript = ''
    session_cookie = "ccv-session=Y2N2LXNlc3Npb246dGVzdHBhc3N3b3JkMTIz"

    start_all()

    # Test localhost-only configuration
    local.wait_for_unit("claude-code-viewer.service")
    local.wait_until_succeeds("curl -sf http://127.0.0.1:3400/")

    # Test public server with password
    server.wait_for_unit("claude-code-viewer.service")
    server.wait_until_succeeds("curl -sf http://127.0.0.1:3400/")

    # Test that unauthenticated API request is rejected (401)
    server.succeed("curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:3400/api/projects | grep -q 401")

    # Test that authenticated API request succeeds
    server.succeed(f"curl -sf -H 'Cookie: {session_cookie}' http://127.0.0.1:3400/api/projects")

    # Test that server is accessible from local node (cross-node, tests openFirewall)
    local.wait_until_succeeds("curl -sf http://server:3400/")

    # Test that unauthenticated API request from remote is also rejected
    local.succeed("curl -s -o /dev/null -w '%{http_code}' http://server:3400/api/projects | grep -q 401")

    # Test that authenticated API request from remote succeeds
    local.succeed(f"curl -sf -H 'Cookie: {session_cookie}' http://server:3400/api/projects")

    # Test that local (bound to 127.0.0.1) is NOT accessible from server
    server.fail("curl -sf --connect-timeout 2 http://local:3400/")
  '';
}
