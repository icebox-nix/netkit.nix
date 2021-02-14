{
  description = "Versatile tools for advanced networking scenarios in NixOS.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    with flake-utils.lib;
    with nixpkgs.lib;
    with builtins;
    let
      defaultSystem = "x86_64-linux";

      # Adapted from nixos-cn/flakes
      mergeSets = foldl (a: b: (a // b)) { };
      listFiles = dir: map (n: dir + "/${n}") (attrNames (readDir dir));
      listNixFilesRecursive = dir:
        flatten (mapAttrsToList (name: type:
          let path = dir + "/${name}";
          in if type == "directory" then
            if pathExists (dir + "/${name}/default.nix") then
              path
            else
              listNixFilesRecursive path
          else if hasSuffix ".nix" name then
            path
          else
            [ ]) (readDir dir));

      filterBySystem = system: pkgs:
        filterAttrsRecursive (_: p:
          # If there is a platform indication
          !(isDerivation p) || (if hasAttrByPath [ "meta" "platforms" ] p then
            elem system p.meta.platforms
          else
            system == defaultSystem)) pkgs;
      getPackages = f: dir:
        listToAttrs (map (name: {
          inherit name;
          value = f (dir + "/${name}");
        }) (attrNames (readDir dir)));
      # Make regular package sets (direct callPackage)
      makePackageSet = f: dirs: mergeSets (map (dir: (getPackages f dir)) dirs);
      aggregatePkgSets = f: dir:
        mergeSets (map (name: f (dir + "/${name}")) (attrNames (readDir dir)));

      pkgSet = nixpkgs:
        (makePackageSet (n: nixpkgs.callPackage n { }) [
          ./pkgs/data
          ./pkgs/tools
        ])
        // (aggregatePkgSets (n: import n { inherit nixpkgs; }) ./pkgs/drivers);
    in (eachDefaultSystem (system:
      let
        pkgs = (import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        });
      in rec {
        packages = filterBySystem system (pkgSet pkgs);

        checks = packages;
      })) // {
        publicKey =
          "lexuge.cachix.org-1:RRFg8AxcexeBd33smnmcayMLU6r2wbVKbZHWtg2dKnY=";

        overlay = final: prev: { netkit = recurseIntoAttrs (pkgSet prev); };
        nixosModule = { ... }: {
          nixpkgs.overlays = [ self.overlay ];
          imports = listNixFilesRecursive ./modules;
        };
      };
}
