{ pkgs, localLispPackages, ... }:

pkgs.lispPackages.buildLispPackage {
  baseName = "fare-mop";
  packageName = "fare-mop";
  description = "fare-mop has a few simple utilities relying on the MOP.";

  buildSystems = [ "fare-mop" ];

  deps = with localLispPackages; [
    closer-mop
    fare-utils
  ];

  src = pkgs.fetchgit {
    url    = "https://github.com/fare/fare-mop.git";
    rev    = "538aa94590a0354f382eddd9238934763434af30";
    sha256 = "0maxs8392953fhnaa6zwnm2mdbhxjxipp4g4rvypm06ixr6pyv1c";
    fetchSubmodules = false;
  };

  asdFilesToKeep = [ "fare-mop.asd" ];
}
