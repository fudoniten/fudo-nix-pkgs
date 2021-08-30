# NOT USED, CAN DELETE

{ pkgs, ... }:

let version = "3.3";

in pkgs.stdenv.mkDerivation {
  pname = "vanilla-forum";
  version = version;

  src = builtins.fetchurl {
    name = "vanilla-forum-${version}.zip";
    url = "https://us.v-cdn.net/5018160/uploads/addons/3JQXC5NIGUWR.zip";
    sha256 = "13062ar0mdaaihzj6jx9kjvfvsg3km8khvad1rm9cqxviim9rzv3";
  };

  nativeBuildInputs = with pkgs; [ unzip ];

  installPhase = ''
    mkdir $out
    cp -aR -t $out applications bootstrap.php dist js library locales plugins resources themes uploads vendor
  '';

  meta = {
    homepage = "http://vanillaforums.com/";
    description = "Vanilla Web Forum";
    downloadPage = "https://open.vanillaforums.com/download";
  };
}
