{ rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "dcompass";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "LEXUGE";
    repo = pname;
    rev = "4da162b756ce11b88ea49ec640cd1e47fc1f282c";
    sha256 = "0m59c88j8d3g2fn5xq6h8z6rhr0ls7c0k4my7c536sa0dnzvh7ax";
  };

  cargoSha256 = "0vgb1vnbyzpl8ahcis4k2l7zpc8q7ydikpgdaqnkcbl553fshxv0";
}
