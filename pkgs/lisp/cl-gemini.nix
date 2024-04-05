{ pkgs, localLispPackages, ... }:

let
  url = "https://fudo.dev/informis/cl-gemini.git";
  rev = "9dcb1674cd00bb5a5e4d0fcb3ef6c6a8e7dbb72c";
  sha256 = "19sj576hk9xl7hqcydqsgqs3xl8r4jg658dwcvcw9gh8j901r65d";

in pkgs.lispPackages.buildLispPackage {
  baseName = "cl-gemini";
  packageName = "cl-gemini";
  description = "Gemini server written in Common Lisp.";

  buildSystems = [ "cl-gemini" ];

  src = pkgs.fetchgit {
    url = url;
    rev = rev;
    sha256 = sha256;
    fetchSubmodules = false;
  };

  deps = with localLispPackages; [
    alexandria
    arrows
    asdf-package-system
    asdf-system-connections
    cl_plus_ssl
    cl-ppcre
    fare-mop
    file-types
    inferior-shell
    local-time
    osicat
    quicklisp
    quri
    slynk
    # slynk-asdf
    slynk-macrostep
    slynk-stepper
    uiop
    usocket-server
    xml-emitter
  ];

  asdFilesToKeep = [ "cl-gemini.asd" ];
}
