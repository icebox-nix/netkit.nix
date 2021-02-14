{ lib, yarn2nix-moretea, fetchFromGitHub }:

yarn2nix-moretea.mkYarnPackage rec {
  name = "yacd";

  # Use `nix-prefetch-url --unpack https://github.com/haishanh/yacd/archive/{version}.tar.gz` to update
  src = fetchFromGitHub {
    owner = "haishanh";
    repo = "yacd";
    rev = "v0.2.12";
    sha256 = "sha256-n0gMW+DWUD/XDJHCdt5LyQQZhWT9E8TlgO53+mky4Xk=";
  };

  packageJSON = "${src}/package.json";
  yarnLock = "${src}/yarn.lock";

  # Since mkYarnPackage moves content of . to ./deps/${pname}, original path should be patched.
  prePatch = ''
    substituteInPlace ./src/components/Root.css \
      --replace '../../node_modules' '../../../../node_modules'
  '';

  buildPhase = ''
    yarn build
  '';

  # installPhase should not be overwritten since it is useful for distPhase.
  postInstall = ''
    cp -r $out/libexec/yacd/deps/yacd/public/* $out/bin/
  '';

  meta = with lib; {
    description = "Yet Another Clash Dashboard";
    homepage = "https://github.com/haishanh/yacd";
    license = licenses.free;
    platforms = [ "x86_64-linux" ];
  };
}
