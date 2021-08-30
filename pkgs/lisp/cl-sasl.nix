{ pkgs, ... }:

pkgs.lispPackages.buildLispPackage {
  description = "SASL package for common lisp";
  baseName = "cl-sasl";
  packageName = "cl-sasl";

  buildSystems = [ "cl-sasl" ];

  deps = with pkgs.lispPackages; [
    ironclad
  ];

  src = pkgs.fetchFromGitHub {
    owner  = "legoscia";
    repo   = "cl-sasl";
    rev    = "64f195c0756cb80fa5961c072b62907be20a7380";
    sha256 = "0a05q8rls2hn46rbbk6w5km9kqvhsj365zlw6hp32724xy2nd98w";
  };

  asdFilesToKeep = [ "cl-sasl.asd" ];
}
