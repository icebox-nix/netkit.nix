self:
{ lib, pkgs, config, ... }:

with lib;

let
  cfg = config.netkit.overture;
  confFile =
    pkgs.writeText "overture-config.json" (generators.toJSON { } cfg.settings);
in {
  options.netkit.overture = {
    enable = mkEnableOption "AtomDNS DNS server";

    settings = mkOption {
      type = types.unspecified;
      description = ''
        Configuration file in JSON. See <link xlink:href="https://github.com/shawn1m/overture">Overture DNS README</link> for details.
      '';
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [ self.overlays.tools ];

    users.users.overture = {
      description = "overture user";
      isSystemUser = true;
    };

    systemd.services.overture = {
      description = "Overture DNS service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      script = "${pkgs.overture}/bin/overture -v -c ${confFile}";
      serviceConfig = {
        # CAP_NET_BIND_SERVICE: Bind arbitary ports by unprivileged user.
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        User = "overture";
        Restart = "on-failure";
      };
    };
  };
}