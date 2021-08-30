{ pkgs, localLispPackages, ... }:

pkgs.lispPackages.buildLispPackage {
  baseName = "inferior-shell";
  packageName = "inferior-shell";
  description = "This CL library allows you to spawn local or remote processes and shell pipes.";

  buildSystems = [ "inferior-shell" ];

  deps = with localLispPackages; [
    pkgs.asdf
    alexandria
    fare-mop
    fare-quasiquote-extras
    fare-utils
    trivia
    trivia_dot_quasiquote
  ];

  src = pkgs.fetchgit {
    url    = "https://github.com/fare/inferior-shell.git";
    rev    = "15c2d04a7398db965ea1c3ba2d49efa7c851f2c2";
    sha256 = "02qx37zzk5j4xmwh77k2qa2wvnzvaj6qml5dh2q7b6b1ljvgcj4m";
    fetchSubmodules = false;
  };

  asdFilesToKeep = [ "inferior-shell.asd" ];
}
