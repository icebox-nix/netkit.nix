{ rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "dcompass";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "LEXUGE";
    repo = pname;
    rev = "c0a9e962b4a54e978b4553f2432f2ee155ee4fc1";
    sha256 = "0gkmq1p30s6lji1l59r01sbp74jwi9c21bs4i0jmq3s89p3fj2nd";
  };

  cargoSha256 = "18ajpvds0bvys7y7nlmbwa5i880vh123cvwps1751hc98xbq5agc";
}
