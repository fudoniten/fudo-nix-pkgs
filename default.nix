{ pkgs, lib, ... }:

let
  callPackage = pkgs.callPackage;

in {
  nixpkgs.config.packageOverrides = pkgs: rec {

    letsencrypt-ca = callPackage ./pkgs/letsencrypt-ca.nix { };

    minecraft-current = pkgs.minecraft-server_1_17_1;

    minecraft-server_1_15_1 = pkgs.minecraft-server.overrideAttrs
      (oldAttrs: rec {
        version = "1.15.1";
        src = builtins.fetchurl {
          url =
            "https://launcher.mojang.com/v1/objects/4d1826eebac84847c71a77f9349cc22afd0cf0a1/server.jar";
          sha256 =
            "a0c062686bee5a92d60802ca74d198548481802193a70dda6d5fe7ecb7207993";
        };
      });

    minecraft-server_1_16_1 = let
      version = "1.16.1";
      url =
        "https://launcher.mojang.com/v1/objects/a412fd69db1f81db3f511c1463fd304675244077/server.jar";
      sha256 = "0nwkdig6yw4cnm2ld78z4j4xzhbm1rwv55vfxz0gzhsbf93xb0i7";
    in (pkgs.minecraft-server.overrideAttrs (oldAttrs: rec {
      name = "minecraft-server-${version}";
      inherit version;
      src = pkgs.fetchurl { inherit url sha256; };
    }));

    minecraft-server_1_16_2 = let
      version = "1.16.2";
      url =
        "https://launcher.mojang.com/v1/objects/c5f6fb23c3876461d46ec380421e42b289789530/server.jar";
      sha256 = "0fbghwrj9b2y9lkn2b17id4ghglwvyvcc8065h582ksfz0zys0i9";
    in (pkgs.minecraft-server.overrideAttrs (oldAttrs: rec {
      name = "minecraft-server-${version}";
      inherit version;
      src = pkgs.fetchurl { inherit url sha256; };
    }));

    minecraft-server_1_16_4 = pkgs.minecraft-server.overrideAttrs
      (oldAttrs: rec {
        version = "1.15.1";
        src = builtins.fetchurl {
          url =
            "https://launcher.mojang.com/v1/objects/35139deedbd5182953cf1caa23835da59ca3d7cd/server.jar";
          sha256 = "01i5nd03sbnffbyni1fa6hsg5yll2h19vfrpcydlivx10gck0ka4";
        };
      });
    
    minecraft-server_1_17_1 = pkgs.minecraft-server.overrideAttrs
      (oldAttrs: rec {
        version = "1.17.1";
        src = builtins.fetchurl {
          url =
            "https://launcher.mojang.com/v1/objects/a16d67e5807f57fc4e550299cf20226194497dc2/server.jar";
          sha256 = "0pzmzagvrrapjsnd8xg4lqwynwnb5rcqk2n9h2kzba8p2fs13hp8";
        };
      });

    postgresql_11_gssapi = pkgs.postgresql_11.overrideAttrs (oldAttrs: rec {
      configureFlags = oldAttrs.configureFlags ++ [ "--with-gssapi" ];
      buildInputs = oldAttrs.buildInputs ++ [ pkgs.krb5 ];
    });

    postgresql_12_gssapi = pkgs.postgresql_12.overrideAttrs (oldAttrs: rec {
      configureFlags = oldAttrs.configureFlags ++ [ "--with-gssapi" ];
      buildInputs = oldAttrs.buildInputs ++ [ pkgs.krb5 ];
    });

    opencv-java = pkgs.opencv.overrideAttrs (oldAttrs: rec {
      # buildInputs = oldAttrs.buildInputs ++ [ pkgs.ant ];
      pname = "opencv-java";
      nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ pkgs.jdk11 pkgs.ant ];
      cmakeFlags = oldAttrs.cmakeFlags ++ [ "-DWITH_JAVA=ON" ];
    });

    hll2380dw-cups = callPackage ./pkgs/hll2380dw-cups.nix { };

    hll2380dw-lpr = callPackage ./pkgs/hll2380dw-lp.nix { };

    backplane-dns-client = callPackage ./pkgs/backplane-dns-client.nix { };

    cl-gemini = callPackage ./pkgs/cl-gemini.nix { inherit localLispPackages; };
    
    fudo-service = callPackage ./pkgs/fudo-service.nix { };

    google-photos-uploader = callPackage ./pkgs/google-photo-uploader.nix { };

    ## 
    ## Check this in once, then delete it
    ## 
    # doomEmacsInit = pkgs.writeShellScriptBin "doom-emacs-init.sh" ''
    #   DOOMDIR=$HOME/.emacs.d

    #   function clone_into() {
    #     ${pkgs.git}/bin/git clone https://github.com/hlissner/doom-emacs.git $1
    #   }

    #   if [ ! -d "$DOOMDIR" ]; then
    #     clone_into $DOOMDIR
    #     $DOOMDIR/bin/doom -y install
    #   fi

    #   if [ ! -f $DOOMDIR/bin/doom ]; then
    #     # legacy...move to a backup
    #     mv $HOME/.emacs.d $HOME/.emacs.d.bak
    #     mv $HOME/.emacs $HOME/.emacs.bak
    #     clone_into $DOOMDIR
    #     $DOOMDIR/bin/doom -y install
    #   fi

    #   $DOOMDIR/bin/doom sync

    #   #if ${pkgs.emacs}/bin/emacsclient -ca false -e '(delete-frame)'; then
    #   #  # emacs is running
    #   #  ${pkgs.emacs}/bin/emacsclient -e '(doom/reload)'
    #   #fi
    # '';

    localLispPackages = (callPackage ./pkgs/lisp { inherit localLispPackages; })
      // pkgs.lispPackages;

    backplane-dns-server = callPackage ./backplane-dns-server.nix {
      inherit localLispPackages;
    };

    doom-emacs-config = builtins.fetchGit {
      url = "https://git.fudo.org/niten/doom-emacs.git";
    };

    vanilla-forum = callPackage ./vanilla-forum.nix { };

    openttd-data = pkgs.fetchgit {
      url = "https://git.fudo.org/fudo-public/openttd-data.git";
      rev = "5b7dd0ca9014e642e1f2d0aa3154b5da869911d3";
      sha256 = "061k0f0jgm5k81djslb172xk0wkis0m878izgisyj2qgg3wf1awh";
    };

    textfiles = pkgs.fetchgit {
      url = "https://git.informis.land/informis/textfiles.git";
      rev = "278a90f7ce219e36e5de0a80b540e469a9bce912";
      sha256 = "06qns3ayc84mamdgn0jw652rvx60wy9km1vxm2361mzmx2zk89iw";
    };

    clj2nix = pkgs.callPackage (pkgs.fetchgit {
      url = "https://github.com/hlolli/clj2nix.git";
      rev = "e6d09dd8c5cda68eb0534bd8501f2d5dcd7b2e95";
      sha256 = "0v0q6iglr0lx13j1snzd8mjxids1af1p2h7bkvmsyk2bfp36naqx";
    }) { };

    flatpak = pkgs.callPackage ./pkgs/flatpak { };
  };
}
