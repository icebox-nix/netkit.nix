{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  name = "update-node2nix";
  buildInputs = [ pkgs.nodePackages.node2nix ];
  shellHook = ''
    node2nix -i deps.json
    mv default.nix node.nix
    exit
  '';
}
