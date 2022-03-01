{ pkgs, localLispPackages, ... }:

pkgs.lispPackages.buildLispPackage {
  baseName = "backplane-dns";
  packageName = "backplane-dns";
  description = "XMPP Backplane DNS Server";

  buildSystems = [ "backplane-dns" ];

  src = pkgs.fetchgit {
    url = "https://git.fudo.org/fudo-public/backplane-dns.git";
    rev = "46458f11aafbd8b5d533b588c63e97e641667c32";
    sha256 = "0wvnikw44q3a4x031ywdwf440bpvd45zbfnyivrmq1ri4bb8ffd5";
    fetchSubmodules = false;
  };

  deps = with localLispPackages; [
    arrows
    alexandria
    backplane-server
    cl-ppcre
    ip-utils
    postmodern
    prove
    trivia
  ];

  asdFilesToKeep = [ "backplane-dns.asd" ];
}
