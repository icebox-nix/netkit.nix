{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.netkit.xmm7360;
  xmm7360ConfigFile =
    pkgs.writeText "xmm7360.ini" (generators.toKeyValue { } cfg.config);
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
      type = with types; attrsOf (oneOf [ bool int str ]);
      description = "xmm7360.ini config file (no section names required).";
      default = { };
    };
    package = mkOption {
      type = types.package;
      description =
        "Kernel Module Package of XMM7360-PCI to use. Make sure that this matches up with your kernel version.";
    };
  };

  config = mkIf cfg.enable {
    boot.extraModulePackages = [ cfg.package ];

    # Currently, due to absence of power management, xmm7360 needs to be brought down and reconnected on resume.
    std.misc.restartOnResumeServices = [ "xmm7360" ];
    systemd.services.xmm7360 = let
      inherit (pkgs) kmod;
      # Be ensured that the device is freshly booted
      preStartScript = pkgs.writeShellScript "xmm7360-poststop" ''
        ${kmod}/bin/modprobe xmm7360 || true
        echo "Module loading completed"
      '';
      # Clean up whatever, including bringing the interface down and delete it anyway.
      postStopScript = pkgs.writeShellScript "xmm7360-poststop" ''
        ${kmod}/bin/rmmod xmm7360 || true
      '';
    in {
      wantedBy = lib.optionals (cfg.autoStart) [ "multi-user.target" ];
      description = "Configuration service for Fibocom L850-GL";
      # Sleep for 10 seconds to make sure that device is fully up.
      # Include it here in ExecStart so that it would block the activation process anyway.
      script = ''
        sleep 10
        ${cfg.package}/bin/open_xdatachannel.py -c ${xmm7360ConfigFile}
      '';
      serviceConfig = {
        # We want to keep it up, else the rules set up are discarded immediately.
        Type = "oneshot";
        RemainAfterExit = true; # Used together with oneshot
        TimeoutStartSec = "1min 30s"; # Timeout if it can't start and try again
        ExecStartPre = preStartScript;
        # Clean-up
        ExecStopPost = postStopScript;
        Restart = "on-failure";
        # SuccessExitStatus = 1;
      };
    };
  };
}
