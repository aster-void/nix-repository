{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.programs.hazkey;
  fcitx5-hazkey = import ../../../packages/fcitx5-hazkey {inherit pkgs;};
in {
  _class = "homeManager";

  options.programs.hazkey = {
    enable = lib.mkEnableOption "hazkey";
    package = lib.mkOption {
      type = lib.types.package;
      default = fcitx5-hazkey;
      description = "The package to use for fcitx5-hazkey";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.hazkey-server = {
      Unit = {
        Description = "Hazkey server";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${cfg.package}/bin/hazkey-server";
        Restart = "on-failure";
        Environment = [
          "HAZKEY_DICTIONARY=${cfg.package}/share/hazkey/Dictionary"
          "HAZKEY_ZENZAI_MODEL=${cfg.package}/share/hazkey/zenzai.gguf"
        ];
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
