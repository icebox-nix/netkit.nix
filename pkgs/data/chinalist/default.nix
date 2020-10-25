{ stdenv, fetchFromGitHub, format ? "raw", server ? "china" }:

stdenv.mkDerivation rec {
  pname = "chinalist-${format}";
  version = "2020-09-26";

  src = fetchFromGitHub {
    owner = "felixonmars";
    repo = "dnsmasq-china-list";
    rev = "8b91f53b703cb250213a604d6f84c199bcbada74";
    sha256 = "027ncbaiigq3jjjak973bd3j7n64xz8agzlzamg5n1vdgfkc1bbq";
  };

  makeFlags = [ format "SERVER=${server}" ];

  installPhase = ''
    mkdir $out
    cp ./accelerated-domains*${format}* $out
    cp ./google*${format}* $out
    cp ./apple*${format}* $out
  '';
}
