{ pkgs, localLispPackages, ... }:

pkgs.lispPackages.buildLispPackage {
  baseName = "osicat";
  packageName = "osicat";
  description = "Osicat is a lightweight operating system interface for Common Lisp on Unix-platforms.";

  buildSystems = [ "osicat" ];

  deps = with localLispPackages; [
    alexandria
    cffi-grovel
    trivial-features
  ];

  src = pkgs.fetchgit {
    url    = "https://github.com/osicat/osicat.git";
    rev    = "e635611710fe053b4bbb7e8cc950a524f6061562";
    sha256 = "1lib65qkwkywmnkgnnbqvfypv82rds7cdaygjmi32d337f82ljzg";
    fetchSubmodules = false;
  };

  asdFilesToKeep = [ "osicat.asd" ];
}
