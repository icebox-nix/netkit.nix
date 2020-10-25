{ prev, kernelVer }:
(builtins.listToAttrs (map (v:
  prev.lib.attrsets.nameValuePair "xmm7360-pci_${v}" ((kernel:
    (prev.callPackage ./xmm7360-pci {
      inherit kernel;
      inherit (kernel) stdenv;
    })) prev.pkgs."linux_${v}")) kernelVer))
