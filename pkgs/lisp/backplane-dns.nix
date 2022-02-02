{ pkgs, localLispPackages, ... }:

pkgs.lispPackages.buildLispPackage {
  baseName = "backplane-dns";
  packageName = "backplane-dns";
  description = "XMPP Backplane DNS Server";

  buildSystems = [ "backplane-dns" ];

  src = pkgs.fetchgit {
    url = "https://git.fudo.org/fudo-public/backplane-dns.git";
    rev = "026cc8b25c7315af46123e773dcf7b8807e1e2b1";
    sha256 = "0jgr0df5j4x53a500jfx4aphfc7r981md8g3mgjypf3vah31w7ms";
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
