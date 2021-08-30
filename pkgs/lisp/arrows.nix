{ pkgs, ... }:

pkgs.lispPackages.buildLispPackage {
  baseName = "arrows";
  packageName = "arrows";
  description = "Clojure-style arrows for Common Lisp";

  buildSystems = [ "arrows" ];

  deps = [];

  src = pkgs.fetchgit {
    url    = "https://gitlab.com/Harleqin/arrows.git";
    rev    = "df7cf0067e0132d9697ac8b1a4f1b9c88d4f5382";
    sha256 = "042k9vkssrqx9nhp14wdzm942zgdxvp35mba0p2syz98i75im2yy";
    fetchSubmodules = false;
  };

  asdFilesToKeep = [ "arrows.asd" ];
}
