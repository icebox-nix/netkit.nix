{
  description = "Versatile tools for advanced networking scenarios in NixOS.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs-channels/nixos-unstable";
    std.url = "github:icebox-nix/std";
  };

  outputs = { self, nixpkgs, std }@inputs: {
    overlays = {
      # packages grouped by overlays
      clash = (final: prev: {
        maxmind-geoip =
          (prev.callPackage ./clash/packages/maxmind-geoip.nix { });
        yacd = (prev.callPackage ./clash/packages/yacd.nix { });
      });
    };

    packages.x86_64-linux = {
      maxmind-geoip = (import nixpkgs {
        system = "x86_64-linux";
        overlays = [ self.overlays.clash ];
      }).maxmind-geoip;
      yacd = (import nixpkgs {
        system = "x86_64-linux";
        overlays = [ self.overlays.clash ];
      }).yacd;
    };

    nixosModules = {
      wifi-relay = (import ./wifi-relay);
      clash = (import ./clash self);
      frpc = (import ./frpc);
      minecraft-server = (import ./minecraft-server);
    };
  };
}
