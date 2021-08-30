{ pkgs, localLispPackages, ... }:

pkgs.lispPackages.buildLispPackage {
  baseName = "xml-emitter";
  packageName = "xml-emitter";
  description = "Map Lisp to XML.";

  buildSystems = [ "xml-emitter" ];

  deps = with localLispPackages; [
    cl-utilities
  ];

  src = pkgs.fetchgit {
    url    = "https://github.com/VitoVan/xml-emitter.git";
    rev    = "1a93a5ab084a10f3b527db3043bd0ba5868404bf";
    sha256 = "1w9yx8gc4imimvjqkhq8yzpg3kjrp2y37rjix5c1lnz4s7bxvhk9";
    fetchSubmodules = false;
  };

  asdFilesToKeep = [ "xml-emitter.asd" ];
}
