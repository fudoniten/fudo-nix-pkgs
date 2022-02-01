{ pkgs, localLispPackages, ... }:

pkgs.lispPackages.buildLispPackage {
  baseName = "backplane-dns";
  packageName = "backplane-dns";
  description = "XMPP Backplane DNS Server";

  buildSystems = [ "backplane-dns" ];

  src = pkgs.fetchgit {
    url = "https://git.fudo.org/fudo-public/backplane-dns.git";
    rev = "4cddf5383707d4ae6f7ba8913dd92c6f391dd893";
    sha256 = "1a9qiwqvhazqwk617f0mkysfmakm660war1xpj1w5y7g8c6zdp3d";
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
