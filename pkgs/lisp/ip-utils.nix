{ pkgs, ... }:

pkgs.lispPackages.buildLispPackage {
  baseName = "ip-utils";
  packageName = "ip-utils";
  description = "Simple Common Lisp utility functions for working with IPs";

  buildSystems = [ "ip-utils" ];

  deps = with pkgs.lispPackages; [ cl-ppcre split-sequence trivia ];

  src = pkgs.fetchgit {
    url = "https://fudo.dev/publc/ip-utils.git";
    rev = "bf590d0eeab9496bc47db43c997dfe9f0151163a";
    sha256 = "19n17pdzyl8j0fw82dr8lrjy6hkcagszm8kbyv8qbv2jl80176hp";
    fetchSubmodules = false;
  };

  asdFilesToKeep = [ "ip-utils.asd" ];
}
