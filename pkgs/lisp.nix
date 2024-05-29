{ lispPackages, fetchgit, fetchFromGitHub, ... }:

rec {
  agnostic-lizard = lispPackages.buildLispPackage {
    baseName = "agnostic-lizard";
    packageName = "agnostic-lizard";
    description =
      "Agnostic Lizard is a portable implementation of a code walker and in particular of the macroexpand-all function (and macro) that makes a best effort to be correct while not expecting much beyond what the Common Lisp standard requires.";

    buildSystems = [ "agnostic-lizard" ];

    deps = [ ];

    src = fetchgit {
      url = "https://gitlab.common-lisp.net/mraskin/agnostic-lizard.git";
      rev = "fe3a73719f05901c8819f8995a3ebae738257952";
      sha256 = "0ax78y8w4zlp5dcwyhz2nq7j3shi49qn31dkfg8lv2jlg7mkwh2d";
      fetchSubmodules = false;
    };

    asdFilesToKeep = [ "agnostic-lizard.asd" ];
  };

  arrows = lispPackages.buildLispPackage {
    baseName = "arrows";
    packageName = "arrows";
    description = "Clojure-style arrows for Common Lisp";

    buildSystems = [ "arrows" ];

    deps = [ ];

    src = fetchgit {
      url = "https://gitlab.com/Harleqin/arrows.git";
      rev = "df7cf0067e0132d9697ac8b1a4f1b9c88d4f5382";
      sha256 = "042k9vkssrqx9nhp14wdzm942zgdxvp35mba0p2syz98i75im2yy";
      fetchSubmodules = false;
    };

    asdFilesToKeep = [ "arrows.asd" ];
  };

  # FIXME: ew
  cl-gemini = let
    url = "https://fudo.dev/informis/cl-gemini.git";
    rev = "9dcb1674cd00bb5a5e4d0fcb3ef6c6a8e7dbb72c";
    sha256 = "19sj576hk9xl7hqcydqsgqs3xl8r4jg658dwcvcw9gh8j901r65d";
  in lispPackages.buildLispPackage {
    baseName = "cl-gemini";
    packageName = "cl-gemini";
    description = "Gemini server written in Common Lisp.";

    buildSystems = [ "cl-gemini" ];

    src = fetchgit {
      url = url;
      rev = rev;
      sha256 = sha256;
      fetchSubmodules = false;
    };

    deps = with lispPackages; [
      alexandria
      arrows
      asdf-package-system
      asdf-system-connections
      cl_plus_ssl
      cl-ppcre
      fare-mop
      file-types
      inferior-shell
      local-time
      osicat
      quicklisp
      quri
      slynk
      # slynk-asdf
      slynk-macrostep
      slynk-stepper
      uiop
      usocket-server
      xml-emitter
    ];

    asdFilesToKeep = [ "cl-gemini.asd" ];
  };

  cl-sasl = lispPackages.buildLispPackage {
    description = "SASL package for common lisp";
    baseName = "cl-sasl";
    packageName = "cl-sasl";

    buildSystems = [ "cl-sasl" ];

    deps = with lispPackages; [ ironclad ];

    src = fetchFromGitHub {
      owner = "legoscia";
      repo = "cl-sasl";
      rev = "64f195c0756cb80fa5961c072b62907be20a7380";
      sha256 = "0a05q8rls2hn46rbbk6w5km9kqvhsj365zlw6hp32724xy2nd98w";
    };

    asdFilesToKeep = [ "cl-sasl.asd" ];
  };

  fare-mop = lispPackages.buildLispPackage {
    baseName = "fare-mop";
    packageName = "fare-mop";
    description = "fare-mop has a few simple utilities relying on the MOP.";

    buildSystems = [ "fare-mop" ];

    deps = with lispPackages; [ closer-mop fare-utils ];

    src = fetchgit {
      url = "https://github.com/fare/fare-mop.git";
      rev = "538aa94590a0354f382eddd9238934763434af30";
      sha256 = "0maxs8392953fhnaa6zwnm2mdbhxjxipp4g4rvypm06ixr6pyv1c";
      fetchSubmodules = false;
    };

    asdFilesToKeep = [ "fare-mop.asd" ];
  };

  file-types = lispPackages.buildLispPackage {
    baseName = "file-types";
    packageName = "file-types";
    description =
      "Simple scheme to classify file types in a hierarchical fashion. Includes support for associating and querying MIME types.";

    buildSystems = [ "file-types" ];

    deps = [ ];

    src = fetchgit {
      url = "https://github.com/eugeneia/file-types.git";
      rev = "6f5676b2781f617b6009ae4ce001496ea43b6fac";
      sha256 = "09l67gzjwx7kx237grm709dsj9rkmmm8s3ya6irmcw8nh587inbs";
      fetchSubmodules = false;
    };

    asdFilesToKeep = [ "file-types.asd" ];
  };

  inferior-shell = lispPackages.buildLispPackage {
    baseName = "inferior-shell";
    packageName = "inferior-shell";
    description =
      "This CL library allows you to spawn local or remote processes and shell pipes.";

    buildSystems = [ "inferior-shell" ];

    deps = with lispPackages; [
      pkgs.asdf
      alexandria
      fare-mop
      fare-quasiquote-extras
      fare-utils
      trivia
      trivia_dot_quasiquote
    ];

    src = fetchgit {
      url = "https://github.com/fare/inferior-shell.git";
      rev = "15c2d04a7398db965ea1c3ba2d49efa7c851f2c2";
      sha256 = "02qx37zzk5j4xmwh77k2qa2wvnzvaj6qml5dh2q7b6b1ljvgcj4m";
      fetchSubmodules = false;
    };

    asdFilesToKeep = [ "inferior-shell.asd" ];
  };

  ip-utils = lispPackages.buildLispPackage {
    baseName = "ip-utils";
    packageName = "ip-utils";
    description = "Simple Common Lisp utility functions for working with IPs";

    buildSystems = [ "ip-utils" ];

    deps = with lispPackages; [ cl-ppcre split-sequence trivia ];

    src = fetchgit {
      url = "https://fudo.dev/publc/ip-utils.git";
      rev = "bf590d0eeab9496bc47db43c997dfe9f0151163a";
      sha256 = "19n17pdzyl8j0fw82dr8lrjy6hkcagszm8kbyv8qbv2jl80176hp";
      fetchSubmodules = false;
    };

    asdFilesToKeep = [ "ip-utils.asd" ];
  };

  osicat = lispPackages.buildLispPackage {
    baseName = "osicat";
    packageName = "osicat";
    description =
      "Osicat is a lightweight operating system interface for Common Lisp on Unix-platforms.";

    buildSystems = [ "osicat" ];

    deps = with lispPackages; [ alexandria cffi-grovel trivial-features ];

    src = fetchgit {
      url = "https://github.com/osicat/osicat.git";
      rev = "e635611710fe053b4bbb7e8cc950a524f6061562";
      sha256 = "1lib65qkwkywmnkgnnbqvfypv82rds7cdaygjmi32d337f82ljzg";
      fetchSubmodules = false;
    };

    asdFilesToKeep = [ "osicat.asd" ];
  };

  slynk = lispPackages.buildLispPackage {
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

    deps = [ ];

    src = fetchgit {
      url = "https://github.com/joaotavora/sly.git";
      rev = "1.0.43";
      sha256 = "11yclc8i6gpy26m1yj6bid6da22639zpil1qzj87m5gfvxiv4zg6";
      fetchSubmodules = false;
    };

    asdFilesToKeep = [ "slynk/slynk.asd" ];
  };

  slynk-asdf = lispPackages.buildLispPackage {
    baseName = "slynk-asdf";
    packageName = "slynk-asdf";
    description =
      "SLY-ASDF is a contrib for SLY that adds support for editing ASDF systems, exposing several utilities for working with and loading systems.";

    buildSystems = [ "slynk-asdf" ];

    deps = with lispPackages; [ slynk ];

    src = fetchgit {
      url = "https://github.com/mmgeorge/sly-asdf.git";
      rev = "95ca71ddeb6132c413e1e4352b136f41ed9254f1";
      sha256 = "1dvjwdan3qd3x716zgziy5vbq2972rz8pdqi7b40haqg01f33qf4";
      fetchSubmodules = false;
    };

    asdFilesToKeep = [ "slynk-asdf.asd" ];
  };

  slynk-macrostep = lispPackages.buildLispPackage {
    baseName = "slynk-macrostep";
    packageName = "slynk-macrostep";
    description =
      "sly-macrostep is a SLY contrib for expanding CL macros right inside the source file.";

    buildSystems = [ "slynk-macrostep" ];

    deps = with lispPackages; [ slynk ];

    src = fetchgit {
      url = "https://github.com/joaotavora/sly-macrostep.git";
      rev = "5113e4e926cd752b1d0bcc1508b3ebad5def5fad";
      sha256 = "1nxf28gn4f3n0wnv7nb5sgl36fz175y470zs9hig4kq8cp0yal0r";
      fetchSubmodules = false;
    };

    asdFilesToKeep = [ "slynk-macrostep.asd" ];
  };

  slynk-stepper = lispPackages.buildLispPackage {
    baseName = "slynk-stepper";
    packageName = "slynk-stepper";
    description = "A portable Common Lisp stepper interface.";

    buildSystems = [ "slynk-stepper" ];

    deps = with lispPackages; [ agnostic-lizard slynk ];

    src = fetchgit {
      url = "https://github.com/joaotavora/sly-stepper.git";
      rev = "ec3c0a7f3c8b82926882e5fcfdacf67b86d989f8";
      sha256 = "1hxniaxifdw3m4y4yssgy22xcmmf558wx7rpz66wy5hwybjslf7b";
      fetchSubmodules = false;
    };

    asdFilesToKeep = [ "slynk-stepper.asd" ];
  };

  usocket-server = lispPackages.buildLispPackage {
    baseName = "usocket-server";
    packageName = "usocket-server";
    description =
      "This is the usocket Common Lisp sockets library: a library to bring sockets access to the broadest of common lisp implementations as possible.";

    buildSystems = [ "usocket" "usocket-server" ];

    deps = with lispPackages; [ bordeaux-threads split-sequence ];

    src = fetchgit {
      url = "https://github.com/usocket/usocket.git";
      rev = "0e2c23192a74bd654b43528f41b62ee69a06b821";
      sha256 = "18z49j9hdazvy1bf0hc4w4k9iavm1nagfbrbbp8ry1r3y7np6by6";
      fetchSubmodules = false;
    };

    asdFilesToKeep = [ "usocket.asd" "usocket-server.asd" ];
  };

  xml-emitter = lispPackages.buildLispPackage {
    baseName = "xml-emitter";
    packageName = "xml-emitter";
    description = "Map Lisp to XML.";

    buildSystems = [ "xml-emitter" ];

    deps = with lispPackages; [ cl-utilities ];

    src = fetchgit {
      url = "https://github.com/VitoVan/xml-emitter.git";
      rev = "1a93a5ab084a10f3b527db3043bd0ba5868404bf";
      sha256 = "1w9yx8gc4imimvjqkhq8yzpg3kjrp2y37rjix5c1lnz4s7bxvhk9";
      fetchSubmodules = false;
    };

    asdFilesToKeep = [ "xml-emitter.asd" ];
  };

}
