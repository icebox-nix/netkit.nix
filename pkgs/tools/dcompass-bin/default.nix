{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "dcompass-bin";
  version = "git";

  src = ./dcompass;

  phases = [ "installPhase" ];
  installPhase = ''
    install -D -m755 $src $out/bin/dcompass
  '';
}
