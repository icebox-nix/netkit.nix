{ stdenv, fetchFromGitHub, kernel }:

stdenv.mkDerivation rec {
  pname = "xmm7360-pci";
  version = "2020-01-15-${kernel.version}";

  src = fetchFromGitHub {
    owner = "xmm7360";
    repo = "xmm7360-pci";
    rev = "0060149958d00b9cec87b73cd610c136f69e5275";
    sha256 = "0nr7adlwglpw6hp44x0pq8xhv7kik7nsb8yzbxllvy2v1pinyflv";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags =
    [ "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build" ];

  installPhase = ''
    install -D xmm7360.ko $out/lib/modules/${kernel.modDirVersion}/misc/xmm7360.ko
  '';
}
