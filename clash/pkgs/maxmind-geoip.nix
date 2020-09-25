{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "maxmind-geoip";
  version = "20200912";

  src = fetchurl {
    url =
      "https://github.com/Dreamacro/${pname}/releases/download/${version}/Country.mmdb";
    sha256 = "1l4ms5mwzmxj8mpzkbihay16jm7i2n6k6b5xlvbb627xb1k4kh65";
  };

  phases = [ "installPhase" ];
  installPhase = ''
    install -D -m755 $src $out/Country.mmdb
  '';
}
