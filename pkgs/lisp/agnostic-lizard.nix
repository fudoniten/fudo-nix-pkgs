{ pkgs, localLispPackages, ... }:

pkgs.lispPackages.buildLispPackage {
  baseName = "agnostic-lizard";
  packageName = "agnostic-lizard";
  description = "Agnostic Lizard is a portable implementation of a code walker and in particular of the macroexpand-all function (and macro) that makes a best effort to be correct while not expecting much beyond what the Common Lisp standard requires.";

  buildSystems = [ "agnostic-lizard" ];

  deps = with localLispPackages; [];

  src = pkgs.fetchgit {
    url    = "https://gitlab.common-lisp.net/mraskin/agnostic-lizard.git";
    rev    = "fe3a73719f05901c8819f8995a3ebae738257952";
    sha256 = "0ax78y8w4zlp5dcwyhz2nq7j3shi49qn31dkfg8lv2jlg7mkwh2d";
    fetchSubmodules = false;
  };

  asdFilesToKeep = [ "agnostic-lizard.asd" ];
}
