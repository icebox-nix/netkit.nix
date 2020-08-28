{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.netkit.snapdrop;
  src = pkgs.fetchFromGitHub {
    owner = "RobinLinus";
    repo = "snapdrop";
    rev = "97121c438aa130c1ebf6b902e1404f1760ee80d9";
    sha256 = "1a9kbn6g8z67z14416mm04k1cls2k574lbks8lx6dndwqczir4fy";
  };
in {
  options.netkit.snapdrop = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable snapdrop local instance";
    };
    port = mkOption {
      type = types.port;
      default = 8080;
      description = "Port for snapdrop server to listen on.";
    };
  };

  config = mkIf (cfg.enable) {
    systemd.services.init-snapdrop-docker-network = {
      description = "Create the network bridge snapdrop.";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig.Type = "oneshot";
      script =
        let dockercli = "${config.virtualisation.docker.package}/bin/docker";
        in ''
          # Put a true at the end to prevent getting non-zero return code, which will
          # crash the whole service.
          check=$(${dockercli} network ls | grep "snapdrop" || true)
          if [ -z "$check" ]; then
            ${dockercli} network create snapdrop
          else
            echo "snapdrop already exists in docker"
          fi
        '';
    };

    virtualisation.oci-containers.containers = {
      node = {
        image = "node:lts-alpine";
        user = "root";
        volumes = [
          "${(pkgs.callPackage ./pkgs/snapdrop-node.nix { })}:/home/node/app"
        ];
        workdir = "/home/node/app";
        cmd = [ "node" "index.js" ];
        extraOptions = [ "--network=snapdrop" ];
      };
      nginx = {
        image = "nginx:alpine";
        volumes = [
          "${src}/client:/usr/share/nginx/html"
          "${./nginx.conf}:/etc/nginx/conf.d/default.conf"
        ];
        ports = [ "${toString cfg.port}:80" ];
        cmd = [ "nginx" "-g" "daemon off;" ];
        extraOptions = [ "--network=snapdrop" ];
      };
    };
  };
}
