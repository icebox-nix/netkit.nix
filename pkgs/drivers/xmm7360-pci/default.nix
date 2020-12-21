{ stdenv, fetchFromGitHub, kernel, python3 }:

stdenv.mkDerivation rec {
  pname = "xmm7360-pci";
  version = "2020-01-15";

  src = fetchFromGitHub {
    owner = "xmm7360";
    repo = "xmm7360-pci";
    rev = "0060149958d00b9cec87b73cd610c136f69e5275";
    sha256 = "0nr7adlwglpw6hp44x0pq8xhv7kik7nsb8yzbxllvy2v1pinyflv";
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
}
