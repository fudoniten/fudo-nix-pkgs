{ pkgs, localLispPackages, ... }:

pkgs.lispPackages.buildLispPackage {
  baseName = "backplane-server";
  packageName = "backplane-server";
  description = "XMPP Backplane Server";

  buildSystems = [ "backplane-server" ];

  src = pkgs.fetchgit {
    url = "https://git.fudo.org/fudo-public/backplane-server.git";
    rev = "5b50dd8badf5b5460e9cc7e76e191d274712a3bd";
    sha256 = "18fysksmrbfk131fgazbw1cpaxz47015ashap9y4rswd904dzzss";
    fetchSubmodules = false;
  };

  deps = with localLispPackages; [
    alexandria
    arrows
    asdf-package-system
    asdf-system-connections
    cl-json
    cl-xmpp
    cl_plus_ssl
    prove
  ];

  asdFilesToKeep = [ "backplane-server.asd" ];
}
