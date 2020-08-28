{ pkgs, stdenv, fetchFromGitHub }:
let
  nodeModules = (import ./node.nix {
    inherit pkgs;
    system = stdenv.hostPlatform.system;
  })."snapdrop-git://github.com/LEXUGE/snapdrop-server.git#76c689558cb3e494add0f33a7848e7efe38ab2a9";
in stdenv.mkDerivation rec {
  name = "snapdrop-node";

  phases = [ "installPhase" ];
  installPhase = ''
    cp -r ${nodeModules}/lib/node_modules/snapdrop/ $out
    chmod -R 755 $out
  '';
}
