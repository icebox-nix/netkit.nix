{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.netkit.wifi-relay;
  inherit (config.std.interface) devices;
in {
  options.netkit.wifi-relay = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Wi-Fi relay on the same card.";
    };

    ssid = mkOption {
      type = types.str;
      description = "SSID of the Access Point to be created";
      example = "AP-Relay";
    };

    passphrase = mkOption {
      type = types.str;
      description = "Passphrase of the Access Point to be created";
      example = "mysecret";
    };

    interface = mkOption {
      type = types.enum devices.network-interface;
      description = "Wi-Fi network interface to use";
    };

    dns = mkOption {
      default = "192.168.12.1";
      type = types.str;
      description = "DNS address to advertise through DHCP";
      example = "192.168.12.1, 8.8.8.8, 1.1.1.1";
    };

    unitsAfter = mkOption {
      default = [ ];
      type = with types; listOf str;
      description =
        "List of systemd units should be start after LAN Network is reacheable.";
    };

    autoStart = mkOption {
      default = false;
      type = types.bool;
      description = "Weather start hostapd on startup.";
    };
  };

  config = mkIf (cfg.enable) {
    # "wlan-station0" is for wifi-client managed by network manager, "wlan-ap0" is for hostap
    networking.wlanInterfaces = {
      "wlan-station0" = { device = cfg.interface; };
    };

    networking.networkmanager.unmanaged =
      [ "interface-name:${cfg.interface}" "interface-name:wlan-ap0" ];

    services.hostapd = {
      enable = true;
      interface = "wlan-ap0";
      hwMode = "g";
      wpa = true;
      ssid = cfg.ssid;
      wpaPassphrase = cfg.passphrase;
      extraConfig = ''
        # 1=wpa, 2=wep, 3=both
        auth_algs=1
        wpa_key_mgmt=WPA-PSK
        rsn_pairwise=CCMP
      '';
    };

    # Hostapd refuses to work properly after resume. Restarting on resume solves this problem.
    std.misc.restartOnResumeServices = [ "hostapd" ];

    services.dhcpd4 = {
      enable = true;
      interfaces = [ "wlan-ap0" ];
      extraConfig = ''
        option subnet-mask 255.255.255.0;
        option broadcast-address 192.168.12.255;
        option routers 192.168.12.1;
        option domain-name-servers ${cfg.dns};
        subnet 192.168.12.0 netmask 255.255.255.0 {
          range 192.168.12.100 192.168.12.200;
        }
      '';
    };
    networking.firewall.allowedUDPPorts = [ 53 67 ]; # DNS & DHCP
    services.haveged.enable =
      true; # Sometimes slow connection speeds are attributed to absence of haveged.

    boot.kernel.sysctl."net.ipv4.ip_forward" = 1; # Enable package forwarding.

    # Chain of "requires"
    # This ensures no blocking on the chain. If anything fails or restarts, everything restarts in right order.
    # hostapd -> wifi-relay -> dhcpd4
    systemd.services.hostapd = let
      preStartScript = pkgs.writeShellScript "hostapd-prestart" ''
        ${pkgs.iw}/bin/iw phy ${cfg.interface} interface add wlan-ap0 type managed addr 08:11:96:0e:08:0a
        ${pkgs.iproute}/bin/ip link set wlan-ap0 up
        ${pkgs.iproute}/bin/ip addr add 192.168.12.1/24 dev wlan-ap0
      '';
      postStopScript = pkgs.writeShellScript "hostapd-poststop" ''
        ${pkgs.iproute}/bin/ip addr flush dev wlan-ap0 || true
        ${pkgs.iproute}/bin/ip link set wlan-ap0 down || true
        ${pkgs.iw}/bin/iw dev wlan-ap0 del || true
      '';
    in {
      # Clear all of the dependencies
      wantedBy = mkForce [ ];
      after = mkForce [ ];
      bindsTo = mkForce [ ];
      requiredBy = mkForce [ ];

      requires = [ "wifi-relay.service" ];
      # Keep trying so that it would start up when we need it (turned on the Wi-Fi). This `RestartSec` setting surpasses the `StartLimitInterval`, so it keeps trying.
      unitConfig.PartOf = [ "wifi-relay.service" "dhcpd4.service" ];
      serviceConfig = {
        RestartSec = "30s";
        ExecStartPre = preStartScript;
        ExecStopPost = postStopScript;
      };
    };

    systemd.services.dhcpd4 = {
      # Don't enable this unit
      wantedBy = mkForce [ ];
      after = [ "wifi-relay.service" ];
      before = cfg.unitsAfter;
      unitConfig.PartOf = [ "hostapd.service" "wifi-relay.service" ];
      # Start with the whole chain together, but not on its own.
      serviceConfig.Restart = mkForce "no";
    };

    systemd.services.wifi-relay = let
      inherit (pkgs) iptables gnugrep;
      postStopScript = pkgs.writeShellScript "wifi-relay-poststop" ''
        ${iptables}/bin/iptables-save -c | ${gnugrep}/bin/grep -v "wlan-[A-Za-z ]*0" | ${iptables}/bin/iptables-restore -c
      '';
    in {
      description = "iptables rules for wifi-relay";
      requires = [ "dhcpd4.service" ];
      after = [ "hostapd.service" ];
      unitConfig.PartOf = [ "hostapd.service" "dhcpd4.service" ];
      # NAT the packets if the packet is not going out to our LAN but is from our LAN.
      # ${iptables}/bin/iptables -w -t nat -I POSTROUTING -s 192.168.12.0/24 ! -o wlan-ap0 -j MASQUERADE
      # Accept the packets from wlan-ap0 to forward them to the outer world
      # ${iptables}/bin/iptables -w -I FORWARD -i wlan-ap0 -s 192.168.12.0/24 -j ACCEPT
      # Accept the packets from wlan-station0 to forward them back to the LAN
      # ${iptables}/bin/iptables -w -I FORWARD -i wlan-station0 -d 192.168.12.0/24 -j ACCEPT
      script = ''
        ${iptables}/bin/iptables -w -t nat -I POSTROUTING -s 192.168.12.0/24 ! -o wlan-ap0 -j MASQUERADE
        ${iptables}/bin/iptables -w -I FORWARD -i wlan-ap0 -s 192.168.12.0/24 -j ACCEPT
        ${iptables}/bin/iptables -w -I FORWARD -i wlan-station0 -d 192.168.12.0/24 -j ACCEPT
      '';
      serviceConfig = {
        # We want to keep it up, else the rules set up are discarded immediately.
        Type = "oneshot";
        RemainAfterExit = true; # Used together with oneshot
        ExecStopPost = postStopScript;
      };
    };
  };
}
