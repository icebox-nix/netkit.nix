{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "maxmind-geoip";
  version = "20201212";

  src = fetchurl {
    url =
      "https://github.com/Dreamacro/${pname}/releases/download/${version}/Country.mmdb";
    sha256 = "0q6pq4jkbpsvvd0nyc2k7ag6wv0dsdmzvvikcgsd167bnr91avma";
  };

  phases = [ "installPhase" ];
  installPhase = ''
    install -D -m755 $src $out/Country.mmdb
  '';

  meta = with lib; {
    description = "Maxmind GeoIP database";
    homepage = "https://github.com/Dreamacro/maxmind-geoip";
    license = licenses.unfreeRedistributable;
    platforms = platforms.all;
  };
}
