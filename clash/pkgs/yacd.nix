{ yarn2nix-moretea, fetchFromGitHub }:

yarn2nix-moretea.mkYarnPackage rec {
  name = "yacd";

  src = fetchFromGitHub {
    owner = "haishanh";
    repo = "yacd";
    rev = "v0.2.3";
    sha256 = "10jv2cp6fxsjfm5mvxrxaj5cxxsfynjm7pgzdq81c54hzn74sd43";
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
