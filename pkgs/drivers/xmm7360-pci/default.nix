{ nixpkgs }:
let
  kernelVer = [ "5_4" "latest" "5_14" "5_10" ];
  # We have to ensure the target is linux first in order to evaluate
in if nixpkgs.pkgs.stdenv.isLinux then
  (builtins.listToAttrs (map (v:
    nixpkgs.lib.attrsets.nameValuePair "xmm7360-pci_${v}" ((kernel:
      (nixpkgs.callPackage ./pkgs.nix {
        inherit kernel;
        inherit (kernel) stdenv;
      })) nixpkgs.pkgs."linux_${v}")) kernelVer))
else
  { }
