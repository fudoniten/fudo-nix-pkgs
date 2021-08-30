{ pkgs, localLispPackages, ... }:

pkgs.lispPackages.buildLispPackage {
  baseName = "slynk-macrostep";
  packageName = "slynk-macrostep";
  description = "sly-macrostep is a SLY contrib for expanding CL macros right inside the source file.";

  buildSystems = [ "slynk-macrostep" ];

  deps = with localLispPackages; [
    slynk
  ];

  src = pkgs.fetchgit {
    url    = "https://github.com/joaotavora/sly-macrostep.git";
    rev    = "5113e4e926cd752b1d0bcc1508b3ebad5def5fad";
    sha256 = "1nxf28gn4f3n0wnv7nb5sgl36fz175y470zs9hig4kq8cp0yal0r";
    fetchSubmodules = false;
  };

  asdFilesToKeep = [ "slynk-macrostep.asd" ];
}
