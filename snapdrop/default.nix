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
    users.users.snapdrop = {
      description = "Snapdrop server user";
      isSystemUser = true;
    };

    networking.firewall.allowedTCPPorts = [ (cfg.port) 3344 ];

    systemd.services.snapdrop-node = {
      description = "Backend server for snapdrop";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      script = "${pkgs.nodejs}/bin/node index.js";

      serviceConfig = {
        WorkingDirectory = "${(pkgs.callPackage ./pkgs/snapdrop-node.nix { })}";
        User = "snapdrop";
      };
    };

    services.nginx = {
      enable = true;
      config = ''
        events {}
        http {
          include ${pkgs.nginx}/conf/mime.types;
          server {
              listen     ${toString cfg.port};

              expires epoch;

              location / {
                  root   ${src}/client;
                  index  index.html index.htm;
              }

              location /server {
                  proxy_connect_timeout 300;
                  proxy_pass http://127.0.0.1:3344;
                  proxy_set_header Connection "upgrade";
                  proxy_set_header Upgrade $http_upgrade;
                  proxy_set_header X-Forwarded-for $remote_addr;
              }

              error_page   500 502 503 504  /50x.html;
              location = /50x.html {
                  root   ${src}/client;
              }
          }
        }
      '';
    };
  };
}
