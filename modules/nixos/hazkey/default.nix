{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.programs.hazkey;
  fcitx5-hazkey = import ../../../packages/fcitx5-hazkey {inherit pkgs;};
in {
  _class = "nixos";

  options.programs.hazkey = {
    enable = lib.mkEnableOption "hazkey";
    package = lib.mkOption {
      type = lib.types.package;
      default = fcitx5-hazkey;
      description = "The package to use for fcitx5-hazkey";
    };
  };

  config = lib.mkIf cfg.enable (let
    pkg = cfg.package;
  in {
    systemd.user.services.hazkey-server = {
      description = "Hazkey server";
      wantedBy = ["default.target"];
      serviceConfig = {
        ExecStart = "${pkg}/bin/hazkey-server";
        Restart = "on-failure";
      };
      environment = {
        HAZKEY_DICTIONARY = "${pkg}/share/hazkey/Dictionary";
        HAZKEY_ZENZAI_MODEL = "${pkg}/share/hazkey/zenzai.gguf";
      };
    };
  });
}
