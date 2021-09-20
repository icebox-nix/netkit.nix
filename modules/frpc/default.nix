{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.netkit.frpc;
  frpcConfigFile =
    pkgs.writeText "frpc.ini" (generators.toINI { } cfg.frpcConfig);
in {
  options.netkit.frpc = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable frp client service";
    };
    autoStart = mkOption {
      type = types.bool;
      default = true;
      description = "Start frp client service on boot";
    };
    frpcConfig = mkOption {
      type = with types; attrsOf (attrsOf (oneOf [ bool int str ]));
      description = "frpc.ini config file";
      default = { };
    };
  };

  config = mkIf (cfg.enable) {
    users.users.frpc = {
      description = "frp client service user";
      isSystemUser = true;
      group = "frpc";
    };
    users.groups.frpc = {};

    systemd.services.frpc = {
      description = "frp client service";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = lists.optionals (cfg.autoStart) [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.frp}/bin/frpc -c ${frpcConfigFile}";
        User = "frpc";
        Restart = "on-failure";
        RestartSec = 5;
        # Disable startlimitburst because we never know when would network come.
        StartLimitBurst = 0;
      };
    };
  };
}
