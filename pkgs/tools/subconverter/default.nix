{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "subconverter";
  version = "0.6.4";

  src = fetchzip {
    url =
      "https://github.com/tindy2013/${pname}/releases/download/v${version}/subconverter_linux64.tar.gz";
    sha256 = "sha256-TZ2VGCu0t8hKN/ewbXP1PXYpL9uDr6PionDsaJwOwbE=";
  };

  installPhase = ''
    install -D -m755 $src/subconverter $out/bin/subconverter
  '';
}
