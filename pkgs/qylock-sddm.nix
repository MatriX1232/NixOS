{ pkgs }:

pkgs.stdenvNoCC.mkDerivation {
  pname = "qylock-sddm";
  version = "1.0";

  src = pkgs.fetchFromGitHub {
    owner = "Darkkal44";
    repo = "qylock";
    rev = "main";
    sha256 = "sha256-ZFpTWYRlN8a7Upva5kVa0ISfbJR/aygw0YrzN403HSA=";
  };

  installPhase = ''
    mkdir -p $out/share/sddm/themes/qylock
    cp -r * $out/share/sddm/themes/qylock/
  '';
}
