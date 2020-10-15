{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "dnsmasq-china-list";
  version = "2020-09-26";

  src = fetchFromGitHub {
    owner = "felixonmars";
    repo = "dnsmasq-china-list";
    rev = "8b91f53b703cb250213a604d6f84c199bcbada74";
    sha256 = "027ncbaiigq3jjjak973bd3j7n64xz8agzlzamg5n1vdgfkc1bbq";
  };

  makeFlags = [ "smartdns" "SERVER=china" ];

  installPhase = ''
    install -D accelerated-domains.china.smartdns.conf $out/accelerated-domains.china.smartdns.conf
    install -D google.china.smartdns.conf $out/google.china.smartdns.conf
    install -D apple.china.smartdns.conf $out/apple.china.smartdns.conf
  '';
}
