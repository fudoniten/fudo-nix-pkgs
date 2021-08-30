{ pkgs, localLispPackages, ... }:

pkgs.lispPackages.buildLispPackage {
  baseName = "slynk-asdf";
  packageName = "slynk-asdf";
  description = "SLY-ASDF is a contrib for SLY that adds support for editing ASDF systems, exposing several utilities for working with and loading systems.";

  buildSystems = [ "slynk-asdf" ];

  deps = with localLispPackages; [
    slynk
  ];

  src = pkgs.fetchgit {
    url    = "https://github.com/mmgeorge/sly-asdf.git";
    rev    = "95ca71ddeb6132c413e1e4352b136f41ed9254f1";
    sha256 = "1dvjwdan3qd3x716zgziy5vbq2972rz8pdqi7b40haqg01f33qf4";
    fetchSubmodules = false;
  };

  asdFilesToKeep = [ "slynk-asdf.asd" ];
}
