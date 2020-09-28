{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "dnsmasq-china-list";
  version = "2020-09-26";

  src = fetchFromGitHub {
    owner = "felixonmars";
    repo = "dnsmasq-china-list";
    rev = "cf1d61e80ebdbe9ae4249f087c7add9d4ea28121";
    sha256 = "0066lz8vzza4rqki2gln1wapsmvixf6m6lr8d42h5hmf03qkyifs";
  };

  makeFlags = [ "smartdns" "SERVER=china" ];

  installPhase = ''
    install -D accelerated-domains.china.smartdns.conf $out/accelerated-domains.china.smartdns.conf
    install -D google.china.smartdns.conf $out/google.china.smartdns.conf
    install -D apple.china.smartdns.conf $out/apple.china.smartdns.conf
  '';
}
