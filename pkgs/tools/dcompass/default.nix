{ rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "dcompass";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "LEXUGE";
    repo = pname;
    rev = "92462eeb5563427d6f996ff5ac5c5cb0a6795538";
    sha256 = "1ssv8l4ipil9nqf566zv3dfhja28bgkg25gphczjiiwsmhc0isp6";
  };

  cargoSha256 = "18ajpvds0bvys7y7nlmbwa5i880vh123cvwps1751hc98xbq5agc";
}
