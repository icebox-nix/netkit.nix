{ lib, stdenv, fetchFromGitHub, kernel, python3 }:

stdenv.mkDerivation rec {
  pname = "xmm7360-pci";
  version = "2020-08-02";

  src = fetchFromGitHub {
    owner = "icebox-nix";
    repo = "xmm7360-pci";
    rev = "03ad6150c991299c403085e967d900c031a29c94";
    sha256 = "sha256-yJeZAxzeQY0mBa5akcpPChi8nGo/XzjXR1y1yrif/rM=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  prePatch = ''
    substituteInPlace rpc/open_xdatachannel.py --replace "#!/usr/bin/env python3"  "#!${
      (python3.withPackages
        (ps: [ ps.ConfigArgParse ps.pyroute2 ps.dbus-python ]))
    }/bin/python3"
  '';

  makeFlags =
    [ "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build" ];

  installPhase = ''
    mkdir -p $out/bin/
    install -D xmm7360.ko $out/lib/modules/${kernel.modDirVersion}/misc/xmm7360.ko
    cp rpc/* $out/bin/
  '';

  meta = with lib; {
    description =
      "PCI driver for Fibocom L850-GL modem based on Intel XMM7360 modem";
    homepage = "https://github.com/xmm7360/xmm7360-pci/";
    license = licenses.free;
    platforms = [ "x86_64-linux" ];
  };
}
