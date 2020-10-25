{ fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "atomdns";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "Xuanwo";
    repo = pname;
    rev = "cf235a656b533958b429aabc502ee725e78a8694";
    sha256 = "10pcwr436iv8llnfizqk4wjd4qs91sr8jyrffljzfr77cy3zcpjd";
  };

  vendorSha256 = "0fan2yg8gmjzswk0ifv4prsylq6jr8sj9zjxl0yjmy2pli0n1215";
}
