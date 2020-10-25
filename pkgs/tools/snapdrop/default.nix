{ pkgs, stdenv, fetchFromGitHub }:
let
  nodeModules = (import ./node.nix {
    inherit pkgs;
    system = stdenv.hostPlatform.system;
  })."snapdrop-git://github.com/LEXUGE/snapdrop-server.git#48d0b997204457657f495ee8112cc9e8c5639e74";
in stdenv.mkDerivation rec {
  name = "snapdrop-node";

  phases = [ "installPhase" ];
  installPhase = ''
    cp -r ${nodeModules}/lib/node_modules/snapdrop/ $out
    chmod -R 755 $out
  '';
}
