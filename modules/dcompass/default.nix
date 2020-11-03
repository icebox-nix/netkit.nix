self:
{ lib, pkgs, config, ... }:

with lib;

let
  cfg = config.netkit.overture;
  confFile =
    pkgs.writeText "dcompass-config.json" (generators.toJSON { } cfg.settings);
in {
  options.netkit.overture = {
    enable = mkEnableOption "Dcompass DNS server";

    settings = mkOption {
      type = types.unspecified;
      description = ''
        Configuration file in JSON.
      '';
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [ self.overlays.tools ];

    users.users.dcompass = {
      description = "dcompass user";
      isSystemUser = true;
    };

    systemd.services.overture = {
      description = "Dcompass DNS service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      script = "${pkgs.dcompass}/bin/dcompass -c ${confFile}";
      serviceConfig = {
        # CAP_NET_BIND_SERVICE: Bind arbitary ports by unprivileged user.
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        User = "dcompass";
        Restart = "on-failure";
      };
    };
  };
}
