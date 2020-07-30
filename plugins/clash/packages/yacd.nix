{ yarn2nix-moretea, fetchFromGitHub }:

yarn2nix-moretea.mkYarnPackage rec {
  name = "yacd";

  src = fetchFromGitHub {
    owner = "haishanh";
    repo = "yacd";
    rev = "v0.2.1";
    sha256 = "1scc5lqw79awx01x8knq715g9864ngm2qmy8zmaymnkllv7lrm1g";
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
