{ pkgs, localLispPackages, ... }:

pkgs.lispPackages.buildLispPackage {
  baseName = "backplane-dns";
  packageName = "backplane-dns";
  description = "XMPP Backplane DNS Server";

  buildSystems = [ "backplane-dns" ];

  src = pkgs.fetchgit {
    url = "https://git.fudo.org/fudo-public/backplane-dns.git";
    rev = "28496c9dfb01da9e0d0ac82e68ef4b2282792181";
    sha256 = "0ikkxqk58jsaa9z1s3xbn2yhzmr168izqwhrccj3wa7dyalkqz55";
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
