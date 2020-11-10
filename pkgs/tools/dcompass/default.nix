{ rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "dcompass";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "LEXUGE";
    repo = pname;
    rev = "fb64f057493b723059d5e695e4d92cc694a7368b";
    sha256 = "1lwsfbpc4ic2d0lrqarxybhygbyjn78m57xhazbwj44c9kxas4s9";
  };

  cargoSha256 = "0bqpzxvr70aqhkyy0ag0wjc10jzzdiyrhgv2n87i8z0v4gzyq3jj";
}
