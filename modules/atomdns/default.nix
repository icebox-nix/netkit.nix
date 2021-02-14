{ lib, pkgs, config, ... }:

with lib;

let
  cfg = config.netkit.atomdns;
  confFile = pkgs.writeText "atomdns.hcl" cfg.settings;
in {
  options.netkit.atomdns = {
    enable = mkEnableOption "AtomDNS DNS server";

    settings = mkOption {
      type = types.str;
      description = ''
        Configuration file in HCL2 format. See <link xlink:href="https://github.com/Xuanwo/atomdns">AtomDNS README</link> for details.
      '';
    };
  };

  config = mkIf cfg.enable {
    users.users.atomdns = {
      description = "atomdns user";
      isSystemUser = true;
    };

    systemd.services.atomdns = {
      description = "AtomDNS service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      script = "${pkgs.atomdns}/bin/atomdns ${confFile}";
      serviceConfig = {
        # CAP_NET_BIND_SERVICE: Bind arbitary ports by unprivileged user.
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        User = "atomdns";
        Restart = "on-failure";
      };
    };
  };
}
