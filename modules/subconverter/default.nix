{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.netkit.subconverter;
  configFile = pkgs.writeText "pref.ini" (generators.toINI { } cfg.config);
in {
  options.netkit.subconverter = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable subconverter service.";
    };
    config = mkOption {
      type = with types; attrsOf (attrsOf (oneOf [ bool int str ]));
      description = "pref.ini config file.";
      default = { };
    };
  };

  config = mkIf cfg.enable {
    users.users.subconverter = {
      description = "subconverter user";
      isSystemUser = true;
    };

    systemd.services.subconverter = {
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      description = "Subconverter service";
      script = ''
        ${pkgs.netkit.subconverter}/bin/subconverter -f ${configFile}
      '';
      serviceConfig = {
        User = "dcompass";
        Restart = "on-failure";
      };
    };
  };
}
