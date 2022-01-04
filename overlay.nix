(final: prev: with builtins;
  let
    callPackage = prev.callPackage;
    fetchgit = prev.fetchgit;
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

    opencv-java = prev.opencv.overrideAttrs (oldAttrs: rec {
      # buildInputs = oldAttrs.buildInputs ++ [ pkgs.ant ];
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
      rev = "e6d09dd8c5cda68eb0534bd8501f2d5dcd7b2e95";
      sha256 = "0v0q6iglr0lx13j1snzd8mjxids1af1p2h7bkvmsyk2bfp36naqx";
    }) { };

    signal-desktop = prev.signal-desktop.overrideAttrs (oldAttrs: rec {
      version = "5.26.1";
      src = fetchurl {
        url = "https://updates.signal.org/desktop/apt/pool/main/s/signal-desktop/signal-desktop_${version}_amd64.deb";
        sha256 = "0p9zjy32hfzksp3ib5nsnvymdblz6kjb1wd3qi6v0807l3bnv120";
      };
    });

    backplane-auth = fetchgit {
      url = "https://git.fudo.org/fudo-public/backplane-auth.git";
      rev = "d2df49be7efa06be23a0e81aeaa04aeb68ecb0cf";
      sha256 = "057f1cvfldsfjh3p5k39mvfkw35didf2kp1aiflick8z49rgzgqf";
    };
  })
