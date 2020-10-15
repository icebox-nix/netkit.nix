self:
{ lib, pkgs, config, ... }:

with lib;

let
  inherit (lib.types) attrsOf coercedTo listOf oneOf str int bool nullOr;
  cfg = config.netkit.smartdns;

  confFile = pkgs.writeText "smartdns.conf" (with generators;
    toKeyValue {
      mkKeyValue = mkKeyValueDefault {
        mkValueString = v:
          if isBool v then
            if v then "yes" else "no"
          else
            mkValueStringDefault { } v;
      } " ";
      listsAsDuplicateKeys =
        true; # Allowing duplications because we need to deal with multiple entries with the same key.
    } cfg.settings);
in {
  options.netkit.smartdns = {
    enable = mkEnableOption "SmartDNS DNS server";

    bindPort = mkOption {
      type = types.port;
      default = 53;
      description = "DNS listening port number.";
    };

    china-list = mkOption {
      type = types.bool;
      default = false;
      description = "Enable dnsmasq-china-list.";
    };

    settings = mkOption {
      type = let atom = oneOf [ str int bool ];
      in attrsOf (coercedTo atom toList (listOf atom));
      example = literalExample ''
        {
          bind = ":5353 -no-rule -group example";
          cache-size = 4096;
          server-tls = [ "8.8.8.8:853" "1.1.1.1:853" ];
          server-https = "https://cloudflare-dns.com/dns-query -exclude-default-group";
          prefetch-domain = true;
          speed-check-mode = "ping,tcp:80";
        };
      '';
      description = ''
        A set that will be generated into configuration file, see the <link xlink:href="https://github.com/pymumu/smartdns/blob/master/ReadMe_en.md#configuration-parameter">SmartDNS README</link> for details of configuration parameters.
        You could override the options here like <option>netkit.smartdns.bindPort</option> by writing <literal>settings.bind = ":5353 -no-rule -group example";</literal>.
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    ({
      nixpkgs.overlays = [ self.overlays.smartdns ];
      services.smartdns.settings.bind = mkDefault ":${toString cfg.bindPort}";

      systemd.packages = [ pkgs.smartdns ];
      systemd.services.smartdns.wantedBy = [ "multi-user.target" ];
      environment.etc."smartdns/smartdns.conf".source = confFile;
      environment.etc."default/smartdns".source =
        "${pkgs.smartdns}/etc/default/smartdns";

      # After resume, smartdns doesn't work as well.
      std.misc.restartOnResumeServices = [ "smartdns" ];
    })

    (mkIf (config.networking.networkmanager.enable) {
      # SmartDNS doesn't seem to be working when networking environment is changed. Therefore, we have to restart it automatically.
      networking.networkmanager.dispatcherScripts = [{
        source = pkgs.writeShellScript "1-smartdns-restart"
          "${config.systemd.package}/bin/systemctl try-restart smartdns || true";
        type = "basic";
      }];
    })

    (mkIf (cfg.china-list) {
      netkit.smartdns.settings = {
        conf-file = [
          "${pkgs.china-list}/accelerated-domains.china.smartdns.conf"
          "${pkgs.china-list}/apple.china.smartdns.conf"
          "${pkgs.china-list}/google.china.smartdns.conf"
        ];
      };
    })
  ]);
}
