{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "dcompass-bin";
  version = "2020112610";

  src = fetchurl {
    url =
      "https://github.com/LEXUGE/dcompass/releases/download/build-${version}/dcompass-x86_64-unknown-linux-musl";
    sha256 = "sha256-8Gf8IMs28J3ohU83IHSboKlebDX0GmpMUJM+zhi2gVk=";
  };

  phases = [ "installPhase" ];
  installPhase = ''
    install -D -m755 $src $out/bin/dcompass
  '';
}
