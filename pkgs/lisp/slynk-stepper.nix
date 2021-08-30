{ pkgs, localLispPackages, ... }:

pkgs.lispPackages.buildLispPackage {
  baseName = "slynk-stepper";
  packageName = "slynk-stepper";
  description = "A portable Common Lisp stepper interface.";

  buildSystems = [ "slynk-stepper" ];

  deps = with localLispPackages; [
    agnostic-lizard
    slynk
  ];

  src = pkgs.fetchgit {
    url    = "https://github.com/joaotavora/sly-stepper.git";
    rev    = "ec3c0a7f3c8b82926882e5fcfdacf67b86d989f8";
    sha256 = "1hxniaxifdw3m4y4yssgy22xcmmf558wx7rpz66wy5hwybjslf7b";
    fetchSubmodules = false;
  };

  asdFilesToKeep = [ "slynk-stepper.asd" ];
}
