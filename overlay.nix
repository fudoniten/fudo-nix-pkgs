(final: prev:
  with builtins;
  let
    callPackage = prev.callPackage;
    fetchgit = prev.fetchgit;
    fetchFromGitHub = prev.fetchFromGitHub;
    localLispPackages = final.localLispPackages;

  in {
    letsencrypt-ca = callPackage ./pkgs/letsencrypt-ca.nix { };

    minecraft-current = final.minecraft-server_1_17_1;

    minecraft-server_1_17_1 = prev.minecraft-server.overrideAttrs
      (oldAttrs: rec {
        version = "1.17.1";
        src = fetchurl {
          url =
            "https://launcher.mojang.com/v1/objects/a16d67e5807f57fc4e550299cf20226194497dc2/server.jar";
          sha256 = "0pzmzagvrrapjsnd8xg4lqwynwnb5rcqk2n9h2kzba8p2fs13hp8";
        };
      });

    postgresql_11_gssapi = prev.postgresql_11.overrideAttrs (oldAttrs: rec {
      configureFlags = oldAttrs.configureFlags ++ [ "--with-gssapi" ];
      buildInputs = oldAttrs.buildInputs ++ [ prev.krb5 ];
    });

    postgresql_12_gssapi = prev.postgresql_12.overrideAttrs (oldAttrs: rec {
      configureFlags = oldAttrs.configureFlags ++ [ "--with-gssapi" ];
      buildInputs = oldAttrs.buildInputs ++ [ prev.krb5 ];
    });

    opencv3-java = prev.opencv3.overrideAttrs (oldAttrs: rec {
      pname = "opencv-java";
      nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ prev.jdk11 prev.ant ];
      cmakeFlags = oldAttrs.cmakeFlags ++ [ "-DWITH_JAVA=ON" ];
    });

    localLispPackages = (callPackage ./pkgs/lisp { inherit localLispPackages; })
      // prev.lispPackages;

    hll2380dw-cups = callPackage ./pkgs/hll2380dw-cups.nix { };

    hll2380dw-lpr = callPackage ./pkgs/hll2380dw-lp.nix { };

    backplane-dns-client = callPackage ./pkgs/backplane-dns-client.nix { };

    cl-gemini = callPackage ./pkgs/cl-gemini.nix { inherit localLispPackages; };

    fudo-service = callPackage ./pkgs/fudo-service.nix { };

    google-photos-uploader = callPackage ./pkgs/google-photo-uploader.nix { };

    backplane-dns-server = callPackage ./pkgs/backplane-dns-server.nix {
      inherit localLispPackages;
    };

    vanilla-forum = callPackage ./vanilla-forum.nix { };

    openttd-data = fetchgit {
      url = "https://git.fudo.org/fudo-public/openttd-data.git";
      rev = "5b7dd0ca9014e642e1f2d0aa3154b5da869911d3";
      sha256 = "061k0f0jgm5k81djslb172xk0wkis0m878izgisyj2qgg3wf1awh";
    };

    textfiles = fetchgit {
      url = "https://git.informis.land/informis/textfiles.git";
      rev = "278a90f7ce219e36e5de0a80b540e469a9bce912";
      sha256 = "06qns3ayc84mamdgn0jw652rvx60wy9km1vxm2361mzmx2zk89iw";
    };

    clj2nix = callPackage (fetchgit {
      url = "https://github.com/hlolli/clj2nix.git";
      rev = "3d0a38c954c8e0926f57de1d80d357df05fc2f94";
      sha256 = "0y77b988qdgsrp4w72v1f5rrh33awbps2qdgp2wr2nmmi44541w5";
    }) { };

    signal-desktop = prev.signal-desktop.overrideAttrs (oldAttrs: rec {
      version = "5.26.1";
      src = fetchurl {
        url =
          "https://updates.signal.org/desktop/apt/pool/main/s/signal-desktop/signal-desktop_${version}_amd64.deb";
        sha256 = "0p9zjy32hfzksp3ib5nsnvymdblz6kjb1wd3qi6v0807l3bnv120";
      };
    });

    backplane-auth = fetchgit {
      url = "https://git.fudo.org/fudo-public/backplane-auth.git";
      rev = "31468f6bb7c24ebd513da935c5dba1d6f22780fc";
      sha256 = "1x7bza2c621xhd14hxdn0ahbf3q5fi9smwz3bfpa0xfglz29wdrr";
    };

    discourse-fudo = prev.discourse.overrideAttrs (oldAttrs: rec {
      version = "2.8.0-beta10";
      src = prev.fetchFromGitHub {
        owner = "discourse";
        repo = "discourse";
        rev = "v${version}";
        sha256 = "sha256-11fiwf0wzq93isfqcbxp6rpxajavqiayg9gka7nmzqn6as613qa8";
      };
    });
  })
