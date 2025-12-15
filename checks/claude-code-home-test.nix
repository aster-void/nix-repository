{
  pkgs,
  flake,
  ...
}: let
  home-manager = builtins.getFlake "github:nix-community/home-manager/d441981b200305ebb8e2e2921395f51d207fded6?narHash=sha256-QCgaXEj8036JlfyVM2e5fgKIxoF7IgGRcAi8LkehKvo%3D";

  testPlugin = pkgs.runCommand "test-plugin" {} ''
    mkdir -p $out/commands $out/skills/my-skill
    echo "# Test command" > $out/commands/test.md
    echo "# Test skill" > $out/skills/my-skill/SKILL.md
  '';
in
  pkgs.testers.nixosTest {
    name = "claude-code-module-test";

    nodes.machine = {config, ...}: {
      imports = [home-manager.nixosModules.home-manager];

      users.users.test = {
        isNormalUser = true;
        home = "/home/test";
      };

      home-manager.users.test = {
        imports = [flake.homeModules.claude-code];
        programs.claude-code = {
          enable = true;
          package = null; # don't install claude-code, just test file generation
          plugins = [testPlugin];
        };
        home.stateVersion = "26.05";
      };
    };

    testScript = ''
      start_all()
      machine.wait_for_unit("multi-user.target")

      # Test 1: Plugin commands directory exists
      machine.succeed("test -d /home/test/.claude/commands/test-plugin")
      machine.succeed("test -f /home/test/.claude/commands/test-plugin/test.md")

      # Test 2: Plugin skills directory exists
      machine.succeed("test -d /home/test/.claude/skills/test-plugin")
      machine.succeed("test -f /home/test/.claude/skills/test-plugin/my-skill/SKILL.md")

      # Test 3: File contents are correct
      machine.succeed("grep -q 'Test command' /home/test/.claude/commands/test-plugin/test.md")
      machine.succeed("grep -q 'Test skill' /home/test/.claude/skills/test-plugin/my-skill/SKILL.md")
    '';
  }
