{ pkgs, localLispPackages, ... }:

let
  url = "https://git.informis.land/informis/cl-gemini.git";
  rev = "1d5075c23237deec536f62ed5dc06f3845eacf6b";
  sha256 = "0j7gz3c83cgishsraqvm1dw42x5c1ydx26jrmkvykljyfhisyjpm";
  
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
