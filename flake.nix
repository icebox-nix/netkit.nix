{
  description = "Versatile tools for advanced networking scenarios in NixOS.";

  inputs = {
    nixos.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-cn.url = "github:nixos-cn/flakes";
    flake-utils.url = "github:numtide/flake-utils";
    dcompass.url = "github:LEXUGE/dcompass";
  };

  outputs = { self, nixos, flake-utils, nixos-cn, dcompass, ... }@inputs:
    let
      importer = overlays: system:
        (import nixos {
          system = system;
          overlays = overlays;
        });
      inherit (nixos.lib.attrsets) recursiveUpdate;
      kernelVer = [ "5_4" "latest" "zen" "latest_hardened" ];
    in {
      overlay = (final: prev: (import ./pkgs { inherit kernelVer prev; }));
      overlays = {
        tools = (final: prev: (import ./pkgs/tools prev));
        data = (final: prev: (import ./pkgs/data prev));
        drivers =
          (final: prev: (import ./pkgs/drivers { inherit kernelVer prev; }));
      };

      nixosModules = {
        wifi-relay = (import ./modules/wifi-relay);
        clash = (import ./modules/clash self);
        frpc = (import ./modules/frpc);
        minecraft-server = (import ./modules/minecraft-server);
        snapdrop = (import ./modules/snapdrop nixos-cn);
        xmm7360 = (import ./modules/xmm7360 self);
        smartdns = (import ./modules/smartdns self);
        atomdns = (import ./modules/atomdns self);
        overture = (import ./modules/overture self);
        dcompass = (import ./modules/dcompass self);
        subconverter = (import ./modules/subconverter self);
      };
    } // (flake-utils.lib.eachSystem [ "x86_64-linux" ] (system: {
      packages = ({
        yacd = (importer [ self.overlay ] system).yacd;
        smartdns = (importer [ self.overlay ] system).smartdns;
        atomdns = (importer [ self.overlay ] system).atomdns;
        overture = (importer [ self.overlay ] system).overture;
        subconverter = (importer [ self.overlay ] system).subconverter;
        dcompass = dcompass.packages."${system}".dcompass-cn;
        dcompass-bin = (importer [ self.overlay ] system).dcompass-bin;
        maxmind-geoip = (importer [ self.overlay ] system).maxmind-geoip;
        chinalist-raw = (importer [ self.overlay ] system).chinalist-raw;
        chinalist-overture =
          (importer [ self.overlay ] system).chinalist-overture;
        chinalist-smartdns =
          (importer [ self.overlay ] system).chinalist-smartdns;
      } //
        # XMM7360-PCI kernel module packages
        (builtins.listToAttrs (map (v:
          nixos.lib.attrsets.nameValuePair "xmm7360-pci_${v}"
          (importer [ self.overlay ] system)."xmm7360-pci_${v}") kernelVer)));
    }));
}
