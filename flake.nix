{
  description = "Versatile tools for advanced networking scenarios in NixOS.";

  inputs = {
    nixos.url = "github:NixOS/nixpkgs-channels/nixos-unstable";
    # We claim std as a dependency but not explicitly use it here.
    std.url = "github:icebox-nix/std";
  };

  outputs = { self, nixos, std }@inputs: {
    overlays = {
      # packages grouped by overlays
      clash = (final: prev: {
        maxmind-geoip =
          (prev.callPackage ./clash/packages/maxmind-geoip.nix { });
        yacd = (prev.callPackage ./clash/packages/yacd.nix { });
      });
    };

    packages.x86_64-linux = {
      maxmind-geoip = (import nixos {
        system = "x86_64-linux";
        overlays = [ self.overlays.clash ];
      }).maxmind-geoip;
      yacd = (import nixos {
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
