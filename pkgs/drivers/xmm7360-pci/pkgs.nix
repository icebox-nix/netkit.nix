{ lib, stdenv, fetchFromGitHub, kernel, python3 }:

stdenv.mkDerivation rec {
  pname = "xmm7360-pci";
  version = "2020-01-15";

  src = fetchFromGitHub {
    owner = "xmm7360";
    repo = "xmm7360-pci";
    # https://github.com/xmm7360/xmm7360-pci/issues/96
    rev = "ee2d227ae3a15bff5f254b8ea85881c65bf3c49c";
    sha256 = "sha256-LmX292T3LfYaP43cDMWR6uBaFfzZ8YxV/aDyjKqFlE4=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  prePatch = ''
    substituteInPlace rpc/open_xdatachannel.py --replace "#!/usr/bin/env python3"  "#!${
      (python3.withPackages (ps: [ ps.ConfigArgParse ps.pyroute2 ]))
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
