{ pkgs, localLispPackages, ... }:

pkgs.lispPackages.buildLispPackage {
  baseName = "slynk";
  packageName = "slynk";
  description = "SLY is Sylvester the Cat's Common Lisp IDE for Emacs.";

  buildSystems = [
    "slynk"
    "slynk/arglists"
    "slynk/fancy-inspector"
    "slynk/package-fu"
    "slynk/mrepl"
    "slynk/trace-dialog"
    "slynk/profiler"
    "slynk/stickers"
    "slynk/stickers"
    "slynk/indentation"
    "slynk/retro"
  ];

  deps = with localLispPackages; [];

  src = pkgs.fetchgit {
    url    = "https://github.com/joaotavora/sly.git";
    rev    = "1.0.43";
    sha256 = "11yclc8i6gpy26m1yj6bid6da22639zpil1qzj87m5gfvxiv4zg6";
    fetchSubmodules = false;
  };

  asdFilesToKeep = [ "slynk/slynk.asd" ];
}
