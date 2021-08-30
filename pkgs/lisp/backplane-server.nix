{ pkgs, lib, arrows, cl-xmpp, ... }:

pkgs.lispPackages.buildLispPackage {
  baseName = "backplane-server";
  packageName = "backplane-server";
  description = "XMPP Backplane Server";

  buildSystems = [ "backplane-server" ];

  deps = with pkgs.lispPackages; [ alexandria arrows cl-json cl-xmpp prove ];

  src = pkgs.fetchgit {
    url = "https://git.fudo.org/fudo-public/backplane-server.git";
    rev = "5b50dd8badf5b5460e9cc7e76e191d274712a3bd";
    sha256 = "18fysksmrbfk131fgazbw1cpaxz47015ashap9y4rswd904dzzss";
    fetchSubmodules = false;
  };

  asdFilesToKeep = [ "backplane-server.asd" ];
}
