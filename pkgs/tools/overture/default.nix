{ fetchFromGitHub, buildGoModule, skipVerify ? true }:

buildGoModule rec {
  pname = "overture";
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "shawn1m";
    repo = pname;
    rev = "29cd6672f9865a5acb82b3a465003fe2cda42908";
    sha256 = "1vwm5x653864dkhypwc0zdi6ziqawf9iv74i8svvqbf9j5hnywb9";
  };

  patches = [ ./mix-domain.patch ];

  buildFlagsArray = [ "-ldflags=" "-w" "-s" "-X main.version=${version}" ];

  # Tests require network connection which is unavailable in sandbox.
  doCheck = false;

  postInstall = ''
    mv $out/bin/main $out/bin/overture
    install -D -m644 $src/config.sample.json $out/etc/config.sample.json
    install -D -m644 $src/config.test.json $out/etc/config.test.json
  '';

  vendorSha256 = "1ymcwj52d3zkwxiscdxxlw187aj4j160d71ngi9vi3kycgbr70bk";
}
