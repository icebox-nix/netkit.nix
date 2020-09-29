self:
{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.netkit.xmm7360;
  xmm7360ConfigFile =
    pkgs.writeText "xmm7360.ini" (generators.toINI { } cfg.config);
in {
  options.netkit.xmm7360 = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Fibocom L850-GL WWAN Modem.";
    };
    autoStart = mkOption {
      type = types.bool;
      default = false;
      description = "Start the service on startup.";
    };
    config = mkOption {
      type = with types; attrsOf (attrsOf (oneOf [ bool int str ]));
      description =
        "xmm7360.ini config file (section names are treated as comments).";
      default = { };
    };
    package = mkOption {
      type = types.package;
      description = "Kernel Module Package of XMM7360-PCI to use.";
    };
  };

  config = mkIf cfg.enable {
    boot.extraModulePackages = [ cfg.package ];
    nixpkgs.overlays = [ self.overlays.xmm7360 ];

    std.misc.restartOnResumeServices = [ "xmm7360" ];
    systemd.services.xmm7360 = let
      inherit (pkgs) kmod;
      # Be ensured that the device is freshly booted
      # Sleep for 15 seconds to make sure that device is fully up.
      preStartScript = pkgs.writeShellScript "xmm7360-poststop" ''
        ${kmod}/bin/rmmod xmm7360 || true
        ${kmod}/bin/modprobe xmm7360 || true
        echo "Module loading completed"
        sleep 15
      '';
      # Clean up whatever
      postStopScript = pkgs.writeShellScript "xmm7360-poststop" ''
        ${kmod}/bin/rmmod xmm7360 || true
      '';
    in {
      wantedBy = lib.optionals (cfg.autoStart) [ "multi-user.target" ];
      description = "Configuration service for Fibocom L850-GL";
      script = ''
        ${cfg.package}/bin/open_xdatachannel.py -c ${xmm7360ConfigFile}
      '';
      serviceConfig = {
        # We want to keep it up, else the rules set up are discarded immediately.
        Type = "oneshot";
        RemainAfterExit = true; # Used together with oneshot
        TimeoutStartSec = "1min 30s"; # Timeout if it can't start and try again
        ExecStopPost = postStopScript;
        ExecStartPre = preStartScript;
        Restart = "on-failure";
      };
    };
  };
}
