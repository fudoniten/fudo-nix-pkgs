{ pkgs, localLispPackages, ... }:

pkgs.lispPackages.buildLispPackage {
  baseName = "usocket-server";
  packageName = "usocket-server";
  description = "This is the usocket Common Lisp sockets library: a library to bring sockets access to the broadest of common lisp implementations as possible.";

  buildSystems = [ "usocket" "usocket-server" ];

  deps = with localLispPackages; [
    bordeaux-threads
    split-sequence
  ];

  src = pkgs.fetchgit {
    url    = "https://github.com/usocket/usocket.git";
    rev    = "0e2c23192a74bd654b43528f41b62ee69a06b821";
    sha256 = "18z49j9hdazvy1bf0hc4w4k9iavm1nagfbrbbp8ry1r3y7np6by6";
    fetchSubmodules = false;
  };

  asdFilesToKeep = [ "usocket.asd" "usocket-server.asd" ];
}
