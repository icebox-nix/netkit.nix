{ pkgs, config, lib, ... }:

with lib;

let cfg = config.netkit.snapdrop;
in {
  options.netkit.snapdrop = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable snapdrop local instance";
    };

    package = mkOption {
      type = types.package;
      description = "Package of snapdrop to use. e.g. pkgs.nixoscn.snapdrop";
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

    networking.firewall.allowedTCPPorts = [ (cfg.port) 3000 ];

    systemd.services.snapdrop-node = {
      description = "Backend server for snapdrop";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      script = "${cfg.package}/bin/snapdrop";

      serviceConfig = {
        WorkingDirectory = "${cfg.package}";
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
                  root   ${cfg.package}/lib/share/snapdrop/client;
                  index  index.html index.htm;
              }

              location /server {
                  proxy_connect_timeout 300;
                  proxy_pass http://127.0.0.1:3000;
                  proxy_set_header Connection "upgrade";
                  proxy_set_header Upgrade $http_upgrade;
                  proxy_set_header X-Forwarded-for $remote_addr;
              }

              error_page   500 502 503 504  /50x.html;
              location = /50x.html {
                  root   ${cfg.package}/lib/share/snapdrop/client;
              }
          }
        }
      '';
    };
  };
}
