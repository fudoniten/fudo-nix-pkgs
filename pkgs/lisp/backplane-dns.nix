{ pkgs, localLispPackages, ... }:

pkgs.lispPackages.buildLispPackage {
  baseName = "backplane-dns";
  packageName = "backplane-dns";
  description = "XMPP Backplane DNS Server";

  buildSystems = [ "backplane-dns" ];

  src = pkgs.fetchgit {
    url = "https://git.fudo.org/fudo-public/backplane-dns.git";
    rev = "8847d37724acf98350e1139e5cbdc04ffd7ef7cf";
    sha256 = "0qjawwdibbfc4mc7rphm7gjlddxyh1lh1x8yqqsj64276wsjsc8n";
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
