{ pkgs, stdenv, fetchFromGitHub }:
let
  nodeModules = (import ./node.nix {
    inherit pkgs;
    system = stdenv.hostPlatform.system;
  })."snapdrop-git://github.com/LEXUGE/snapdrop-server.git#42bf1218f7353ba1c46719b8cd9af243e53ea6e8";
in stdenv.mkDerivation rec {
  name = "snapdrop-server-src";

  src = fetchFromGitHub {
    owner = "RobinLinus";
    repo = "snapdrop";
    rev = "97121c438aa130c1ebf6b902e1404f1760ee80d9";
    sha256 = "1a9kbn6g8z67z14416mm04k1cls2k574lbks8lx6dndwqczir4fy";
  };

  phases = [ "installPhase" ];
  installPhase = ''
    cp -r ${nodeModules}/lib/node_modules/snapdrop/ $out
    chmod -R 755 $out
  '';
}
