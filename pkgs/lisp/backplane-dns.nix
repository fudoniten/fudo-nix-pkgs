{ pkgs, backplane-server, arrows, ip-utils, ... }:

pkgs.lispPackages.buildLispPackage {
  baseName = "backplane-dns";
  packageName = "backplane-dns";
  description = "XMPP Backplane DNS Server";

  buildSystems = [ "backplane-dns" ];

  deps = with pkgs.lispPackages; [
    arrows
    alexandria
    backplane-server
    cl-ppcre
    ip-utils
    postmodern
    prove
    trivia
  ];

  src = pkgs.fetchgit {
    url = "https://git.fudo.org/fudo-public/backplane-dns.git";
    rev = "3075453a8ccc8bf285bfc83d84317044590ae060";
    sha256 = "1sdgr9zxqam4c8f7nlkgm77si45j0qvvgj6rav9kd6jz6vqgcbi5";
    fetchSubmodules = false;
  };

  asdFilesToKeep = [ "backplane-dns.asd" ];
}
