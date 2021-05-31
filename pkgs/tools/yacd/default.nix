{ lib, fetchzip, stdenv }:

stdenv.mkDerivation rec {
  pname = "yacd";
  version = "0.2.14";

  src = fetchzip {
    url =
      "https://github.com/haishanh/yacd/releases/download/v${version}/yacd.tar.xz";
    sha256 = "sha256-q5U3XwYb9gwpxPzqhXC8UkDTSUY5291AOZDexNRMFHM=";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp -r . $out/bin
  '';

  meta = with lib; {
    description = "Yet Another Clash Dashboard";
    homepage = "https://github.com/haishanh/yacd";
    license = licenses.free;
    platforms = platforms.all;
  };
}
