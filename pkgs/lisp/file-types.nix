{ pkgs, ... }:

pkgs.lispPackages.buildLispPackage {
  baseName = "file-types";
  packageName = "file-types";
  description = "Simple scheme to classify file types in a hierarchical fashion. Includes support for associating and querying MIME types.";

  buildSystems = [ "file-types" ];

  deps = [];

  src = pkgs.fetchgit {
    url    = "https://github.com/eugeneia/file-types.git";
    rev    = "6f5676b2781f617b6009ae4ce001496ea43b6fac";
    sha256 = "09l67gzjwx7kx237grm709dsj9rkmmm8s3ya6irmcw8nh587inbs";
    fetchSubmodules = false;
  };

  asdFilesToKeep = [ "file-types.asd" ];
}
