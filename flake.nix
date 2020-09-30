{
  description = "Versatile tools for advanced networking scenarios in NixOS.";

  inputs = {
    nixos.url = "github:NixOS/nixpkgs-channels/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixos, flake-utils }@inputs:
    let
      importer = overlays: system:
        (import nixos {
          system = system;
          overlays = overlays;
        });
      inherit (nixos.lib.attrsets) recursiveUpdate;
      kernelVer = [ "5_8" "5_7" "5_4" "latest" ];
    in recursiveUpdate (recursiveUpdate {
      overlays = {
        # packages grouped by overlays
        clash = (final: prev: {
          maxmind-geoip = (prev.callPackage ./clash/pkgs/maxmind-geoip.nix { });
          yacd = (prev.callPackage ./clash/pkgs/yacd.nix { });
        });

        smartdns = (final: prev: {
          smartdns = (prev.callPackage ./smartdns/pkgs/smartdns.nix { });
          china-list = (prev.callPackage ./smartdns/pkgs/china-list.nix { });
        });

        xmm7360 = (final: prev:
          (builtins.listToAttrs (map (v:
            prev.lib.attrsets.nameValuePair "xmm7360-pci_${v}" ((kernel:
              (prev.callPackage ./xmm7360/pkgs/xmm7360-pci.nix {
                inherit kernel;
                inherit (kernel) stdenv;
              })) prev.pkgs."linux_${v}")) kernelVer)));
      };

      nixosModules = {
        wifi-relay = (import ./wifi-relay);
        clash = (import ./clash self);
        frpc = (import ./frpc);
        minecraft-server = (import ./minecraft-server);
        snapdrop = (import ./snapdrop);
        xmm7360 = (import ./xmm7360 self);
        smartdns = (import ./smartdns self);
      };
    } (flake-utils.lib.eachSystem [ "x86_64-linux" ] (system: {
      packages = ({
        yacd = (importer [ self.overlays.clash ] system).yacd;
        smartdns = (importer [ self.overlays.smartdns ] system).smartdns;
        china-list = (importer [ self.overlays.smartdns ] system).china-list;
      } //
        # XMM7360-PCI kernel module packages
        (builtins.listToAttrs (map (v:
          nixos.lib.attrsets.nameValuePair "xmm7360-pci_${v}"
          (importer [ self.overlays.xmm7360 ] system)."xmm7360-pci_${v}")
          kernelVer)));
    }))) (flake-utils.lib.eachDefaultSystem (system: {
      packages.maxmind-geoip =
        (importer [ self.overlays.clash ] system).maxmind-geoip;
    }));
}
