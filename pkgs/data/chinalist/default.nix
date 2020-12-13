{ stdenv, fetchFromGitHub, format ? "raw", server ? "china" }:

stdenv.mkDerivation rec {
  pname = "chinalist-${format}";
  version = "2020-12-14";

  src = fetchFromGitHub {
    owner = "felixonmars";
    repo = "dnsmasq-china-list";
    rev = "ce5b0343efb3264c962fe7942f0282fa6d9ea707";
    sha256 = "1dif1npk9d2wzkxp2m1cwjs5vqq7m78vxlprl8x3pn6abixni4fd";
  };

  patches = [ ./overture.patch ];

  makeFlags = [ format "SERVER=${server}" ];

  installPhase = ''
    mkdir $out
    cp ./*${format}* $out
  '';
}
