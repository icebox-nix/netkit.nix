{ lib, stdenv, fetchFromGitHub, format ? "raw", server ? "china" }:

stdenv.mkDerivation rec {
  pname = "chinalist-${format}";
  version = "2020-12-20";

  src = fetchFromGitHub {
    owner = "felixonmars";
    repo = "dnsmasq-china-list";
    rev = "8de1c98ca3fe533575c916843d4b966f51512f22";
    sha256 = "1lpvd31v8kd5hr6q9sr6ablai9k7zbkrpafxslvfmmj76gm582wd";
  };

  patches = [ ./overture.patch ];

  makeFlags = [ format "SERVER=${server}" ];

  installPhase = ''
    mkdir $out
    cp ./*${format}* $out
  '';

  meta = with lib; {
    description =
      "Chinese-specific configuration to improve your favorite DNS server.";
    longDescription = ''
      Chinese-specific configuration to improve your favorite DNS server. Best partner for chnroutes.
    '';
    homepage = "https://github.com/felixonmars/dnsmasq-china-list";
    license = licenses.free;
    platforms = platforms.all;
  };
}
