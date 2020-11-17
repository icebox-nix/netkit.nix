{ rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "dcompass";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "LEXUGE";
    repo = pname;
    rev = "ef30e58d42112dfcbb5ee216f4c011c8a58fbc11";
    sha256 = "sha256-9cDeOTSahrozpGJG8jvtTQ08vv6zRwkOUd8w1/KI4z4=";
  };

  cargoSha256 = "sha256-mwSCEfzhfpMnY6anHxaGqP7A2WWuAs1QuhZBkmSm2WY=";
}
