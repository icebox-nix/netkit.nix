{
  description = "Versatile tools for advanced networking scenarios in NixOS.";

  inputs = {
    nixos.url = "github:NixOS/nixpkgs-channels/nixos-unstable";
    # We claim std as a dependency but not explicitly use it here.
    std.url = "github:icebox-nix/std";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixos, std, flake-utils }@inputs:
    let
      importer = overlays: system:
        (import nixos {
          system = system;
          overlays = overlays;
        });
      inherit (nixos.lib.attrsets) recursiveUpdate;
    in recursiveUpdate (recursiveUpdate {
      overlays = {
        # packages grouped by overlays
        clash = (final: prev: {
          maxmind-geoip = (prev.callPackage ./clash/pkgs/maxmind-geoip.nix { });
          yacd = (prev.callPackage ./clash/pkgs/yacd.nix { });
        });
      };

      nixosModules = {
        wifi-relay = (import ./wifi-relay);
        clash = (import ./clash self);
        frpc = (import ./frpc);
        minecraft-server = (import ./minecraft-server);
        snapdrop = (import ./snapdrop);
      };
    } (flake-utils.lib.eachSystem [ "x86_64-linux" ] (system: {
      packages.yacd = (importer [ self.overlays.clash ] system).yacd;
    }))) (flake-utils.lib.eachDefaultSystem (system: {
      packages.maxmind-geoip =
        (importer [ self.overlays.clash ] system).maxmind-geoip;
    }));
}
