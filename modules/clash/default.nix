{ pkgs, config, lib, ... }:

with lib;

let
  inherit (pkgs) gnugrep iptables clash;
  inherit (lib) optionalString mkIf;
  cfg = config.netkit.clash;
  inherit (cfg) clashUserName;
  redirProxyPortStr = toString cfg.redirPort;

  # Run iptables 4 and 6 together.
  # helper = ''
  #   ip46tables() {
  #     ${iptables}/bin/iptables -w "$@"
  #     ${
  #       optionalString config.networking.enableIPv6 ''
  #         ${iptables}/bin/ip6tables -w "$@"
  #       ''
  #     }
  #   }
  # '';

  # Clash doesn't work well with IPv6
  helper = ''
    ip46tables() {
      ${iptables}/bin/iptables -w "$@"
    }
  '';

  configPath = config.std.interface.system.dirs.secrets.clash;
  tag = "CLASH_SPEC";

  clashModule = types.submodule {
    options = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Clash transparent proxy module.";
      };

      dashboard.port = mkOption {
        type = types.port;
        default = 3333;
        description = "Port for YACD dashboard to listen on.";
      };

      clashUserName = mkOption {
        type = types.str;
        default = "clash";
        description =
          "The user who would run the clash proxy systemd service. User would be created automatically.";
      };

      redirPort = mkOption {
        type = types.port;
        default = 1081;
        description =
          "Proxy local redir server (<literal>ss-redir</literal>) listen port";
      };

      afterUnits = mkOption {
        type = with types; listOf str;
        default = [ ];
        description =
          "List of systemd units that need to be started after clash. Note this is placed in `before` parameter of clash's systemd config.";
      };

      requireUnits = mkOption {
        type = with types; listOf str;
        default = [ ];
        description =
          "List of systemd units that need to be required by clash.";
      };

      beforeUnits = mkOption {
        type = with types; listOf str;
        default = [ ];
        description =
          "List of systemd units that need to be started before clash. Note this is placed in `after` parameter of clash's systemd config.";
      };
    };
  };
in {
  options.netkit.clash = mkOption {
    type = clashModule;
    default = { };
    description = "Clash system service related configurations";
  };

  config = mkIf (cfg.enable) {
    # Sometimes clash doesn't work well on DNS with captive hotspot
    # std.misc.restartOnResumeServices = [ "clash" ];

    environment.etc."clash/Country.mmdb".source =
      "${pkgs.netkit.maxmind-geoip}/Country.mmdb"; # Bring pre-installed geoip data into directory.
    environment.etc."clash/config.yaml".source = configPath;

    # Yacd
    services.lighttpd = {
      enable = true;
      port = cfg.dashboard.port;
      document-root = "${pkgs.netkit.yacd}/bin";
    };

    users.users.${clashUserName} = {
      description = "Clash deamon user";
      isSystemUser = true;
      group = "clash";
    };
    users.groups.clash = {};

    systemd.services.clash = let
      # Delete the chain to avoid unnecessary incident.
      # ip46tables -t nat -F ${tag}

      # Create a new chain appending at the end.
      # ip46tables -t nat -N ${tag}

      # Don't forward package created by ${clashUserName}. Since after forwarding by clash the packets' owner would be changed to ${clashUserName}, this helps us to avoid dead loop in packet forwarding.
      # ip46tables -t nat -A ${tag} -m owner --uid-owner ${clashUserName} -j RETURN

      # Forward all TCP traffic to the redir port of Clash.
      # ip46tables -t nat -A ${tag} -p tcp -j REDIRECT --to-ports ${redirProxyPortStr}

      # For all TCP traffic on OUTPUT chain, put them into our newly created chain.
      # ip46tables -t nat -A OUTPUT -p tcp -j ${tag}
      preStartScript = pkgs.writeShellScript "clash-prestart" ''
        ${helper}
        ip46tables -t nat -F ${tag}
        ip46tables -t nat -N ${tag}
        ip46tables -t nat -A ${tag} -m owner --uid-owner ${clashUserName} -j RETURN
        ip46tables -t nat -A ${tag} -p tcp -j REDIRECT --to-ports ${redirProxyPortStr}

        ip46tables -t nat -A OUTPUT -p tcp -j ${tag}
      '';

      postStopScript = pkgs.writeShellScript "clash-poststop" ''
        ${iptables}/bin/iptables-save -c|${gnugrep}/bin/grep -v ${tag}|${iptables}/bin/iptables-restore -c
        ${optionalString config.networking.enableIPv6 ''
          ${iptables}/bin/ip6tables-save -c|${gnugrep}/bin/grep -v ${tag}|${iptables}/bin/ip6tables-restore -c
        ''}
      '';
    in {
      description = "Clash networking service";
      after = [ "network.target" ] ++ cfg.beforeUnits;
      before = cfg.afterUnits;
      requires = cfg.requireUnits;
      wantedBy = [ "multi-user.target" ];
      script =
        "exec ${clash}/bin/clash -d /etc/clash"; # We don't need to worry about whether /etc/clash is reachable in Live CD or not. Since it would never be execuated inside LiveCD.

      # Don't start if the config file doesn't exist.
      unitConfig = {
        # NOTE: configPath is for the original config which is linked to the following path.
        ConditionPathExists = "/etc/clash/config.yaml";
      };
      serviceConfig = {
        # Use prefix `+` to run iptables as root.
        ExecStartPre = "+${preStartScript}";
        ExecStopPost = "+${postStopScript}";
        # CAP_NET_BIND_SERVICE: Bind arbitary ports by unprivileged user.
        # CAP_NET_ADMIN: Listen on UDP.
        AmbientCapabilities =
          "CAP_NET_BIND_SERVICE CAP_NET_ADMIN"; # We want additional capabilities upon a unprivileged user.
        User = clashUserName;
        Restart = "on-failure";
      };
    };
  };
}
