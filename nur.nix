{pkgs ? import <nixpkgs> {}}: {
  cargo-compete = import ./packages/cargo-compete {inherit pkgs;};
  fcitx5-hazkey = import ./packages/fcitx5-hazkey {inherit pkgs;};
  chrome-devtools-mcp = import ./packages/chrome-devtools-mcp {inherit pkgs;};
  bibata-cursors-translucent = import ./packages/bibata-cursors-translucent {inherit pkgs;};
  ccusage = import ./packages/ccusage {inherit pkgs;};
  ccusage-codex = import ./packages/ccusage-codex {inherit pkgs;};
  ccusage-mcp = import ./packages/ccusage-mcp {inherit pkgs;};
  claude-code-usage-monitor = import ./packages/claude-code-usage-monitor {inherit pkgs;};
  gwq = import ./packages/gwq {inherit pkgs;};
  helix-gj1118 = import ./packages/helix-gj1118 {inherit pkgs;};
  helix-gj1118-bin = import ./packages/helix-gj1118-bin {inherit pkgs;};
  kiri = import ./packages/kiri {inherit pkgs;};
  lsmcp = import ./packages/lsmcp {inherit pkgs;};
  mcp-language-server = import ./packages/mcp-language-server {inherit pkgs;};
  osgrep = import ./packages/osgrep {inherit pkgs;};
  v-analyzer = import ./packages/v-analyzer {inherit pkgs;};

  modules = {
    hazkey-nixos = ./modules/nixos/hazkey;
    hazkey-home = ./modules/home/hazkey;
    osgrep-home = ./modules/home/osgrep.nix;
  };
}
