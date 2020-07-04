# netkit.nix
Verstile icebox plugins for advanced networking scenarios in NixOS.

# What is it?
Intended to work out-of-box without any complicated configuration, `netkit.nix` is a set of [icebox](https://github.com/icebox-nix/icebox) purely declarative plugins for networking scenarios, such as versatile transparent proxy, sharing Wi-Fi through Wi-Fi.

# How to use it?
Code like this in your `configuration.nix`
```nix
let
  icebox = builtins.fetchTarball
    "https://github.com/icebox-nix/icebox/archive/master.tar.gz";
  netkit = builtins.fetchTarball
    "https://github.com/icebox-nix/netkit.nix/archive/master.tar.gz";
in {
  imports = [
    # Other imports omitted
    "${icebox}"
    "${netkit}"
  ];

  icebox = {
    system = {
      plugins = [ "clash" "wifi-relay" ];
      stateVersion = "19.09"; # Change it!
      configs = {
	    # Configurations for other plugins omitted
        clash = {
          enable = true;
          redirPort =
            7892; # This must be the same with the one in your clash.yaml
        };

        wifi-relay = {
          interface = "wlp0s20f3"; # Change according to your device
          ssid = "netkit.nix";
          passphrase = "88888888";
        };
      };
    };

    # Other parts omitted.
    # NOTE: std may be required but we don't elaborate it here. See prerequisite for detail.
  };
}
```

# List of plugins available
- [Clash](https://github.com/Dreamacro/clash) (`plugins/clash`): transparent proxy module with separated maxmind-geoip package and [yacd](https://github.com/haishanh/yacd) dashboard built-in.
- wifi-relay (`plugins/wifi-relay`): Sharing Wi-Fi connection over Wi-Fi on supported devices using `hostapd` and `dhcpd`.
