{ yarn2nix-moretea, fetchFromGitHub }:

yarn2nix-moretea.mkYarnPackage rec {
  name = "yacd";

  # Use `nix-prefetch-url --unpack https://github.com/haishanh/yacd/archive/{version}.tar.gz` to update
  src = fetchFromGitHub {
    owner = "haishanh";
    repo = "yacd";
    rev = "v0.2.7";
    sha256 = "1l0q2z7fcws1kw492i7qma6dsxh3hyfz9wcxyljw7vd76m9h42vq";
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
}
