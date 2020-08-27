{ pkgs, stdenv, fetchFromGitHub }:
let
  nodeModules = (import ./node.nix {
    inherit pkgs;
    system = stdenv.hostPlatform.system;
  })."snapdrop-git://github.com/LEXUGE/snapdrop-server.git#42bf1218f7353ba1c46719b8cd9af243e53ea6e8";
in stdenv.mkDerivation rec {
  name = "snapdrop-node";

  phases = [ "installPhase" ];
  installPhase = ''
    cp -r ${nodeModules}/lib/node_modules/snapdrop/ $out
    chmod -R 755 $out
  '';
}
