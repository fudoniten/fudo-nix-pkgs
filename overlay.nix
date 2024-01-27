{ unstableNixpkgs, helpers, google-photo-uploader, ... }:

(final: prev:
  with builtins;
  let
    system = prev.system;
    unstable = import unstableNixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    callPackage = prev.callPackage;
    fetchgit = prev.fetchgit;
    fetchFromGitHub = prev.fetchFromGitHub;
    localLispPackages = final.localLispPackages;

  in rec {

    inherit unstable;

    letsencrypt-ca = callPackage ./pkgs/letsencrypt-ca.nix { };

    papermc-current = final.papermc-1_20_4;

    papermc-1_20_4 = callPackage ./pkgs/papermc-current.nix {
      version = "1.20.4.329";
      sha256 = "x1wQVRmq4V5XzflF+X1jcQ9cPEwh1sC/9O3WAqutGhI=";
    };

    papermc-1_20_2 = callPackage ./pkgs/papermc-current.nix {
      version = "1.20.2.223";
      sha256 = "1470dvsr6g6k2qixgk1cl2yx1x44gzsd9hci7vx675sx2gi0gqha";
    };

    papermc-1_20_1 = callPackage ./pkgs/papermc-current.nix {
      version = "1.20.1.69";
      sha256 = "10rxj7mkw04wp21k0nhsxa2bzhvcwnqj1hz4vq98fg4kbnb7dx3j";
    };

    minecraft-current = final.minecraft-server_1_20_4;

    minecraft-server_1_20_4 = prev.minecraft-server.overrideAttrs
      (oldAttrs: rec {
        version = "1.20.4";
        src = fetchurl {
          url =
            "https://piston-data.mojang.com/v1/objects/8dd1a28015f51b1803213892b50b7b4fc76e594d/server.jar";
          sha256 = "0qykf9a3nacklqsyb30kg9m79nw462la6rf92gsdssdakprscgy0";
        };
      });

    minecraft-server_1_20_2 = prev.minecraft-server.overrideAttrs
      (oldAttrs: rec {
        version = "1.20.2";
        src = fetchurl {
          url =
            "https://piston-data.mojang.com/v1/objects/5b868151bd02b41319f54c8d4061b8cae84e665c/server.jar";
          sha256 = "1s7ag1p8v0vyzc6a8mjkd3rcf065hjb4avqa3zj4dbb9hn1y9bhx";
        };
      });

    minecraft-server_1_20_1 = prev.minecraft-server.overrideAttrs
      (oldAttrs: rec {
        version = "1.20.1";
        src = fetchurl {
          url =
            "https://piston-data.mojang.com/v1/objects/84194a2f286ef7c14ed7ce0090dba59902951553/server.jar";
          sha256 = "1q3r3c95vkai477r3gsmf2p0pmyl4zfn0qwl8y0y60m1qnfkmxrs";
        };
      });

    minecraft-server_1_19_4 = prev.minecraft-server.overrideAttrs
      (oldAttrs: rec {
        version = "1.19.4";
        src = fetchurl {
          url =
            "https://piston-data.mojang.com/v1/objects/8f3112a1049751cc472ec13e397eade5336ca7ae/server.jar";
          sha256 = "0lrzpqd6zjvqh9g2byicgh66n43z0hwzp863r22ifx2hll6s2955";
        };
      });

    minecraft-server_1_19_3 = prev.minecraft-server.overrideAttrs
      (oldAttrs: rec {
        version = "1.19.3";
        src = fetchurl {
          url =
            "https://piston-data.mojang.com/v1/objects/c9df48efed58511cdd0213c56b9013a7b5c9ac1f/server.jar";
          sha256 = "06qykz3nq7qmfw4phs3wvq3nk28clg8s3qrs37856aai8b8kmgaf";
        };
      });

    minecraft-server_1_19_2 = prev.minecraft-server.overrideAttrs
      (oldAttrs: rec {
        version = "1.19.2";
        src = fetchurl {
          url =
            "https://piston-data.mojang.com/v1/objects/f69c284232d7c7580bd89a5a4931c3581eae1378/server.jar";
          sha256 = "15jdxh5zvsgvvk9hnv47swgjfg8fr653g6nx99q1rxpmkq32frxj";
        };
      });

    minecraft-server_1_17_1 = prev.minecraft-server.overrideAttrs
      (oldAttrs: rec {
        version = "1.17.1";
        src = fetchurl {
          url =
            "https://launcher.mojang.com/v1/objects/a16d67e5807f57fc4e550299cf20226194497dc2/server.jar";
          sha256 = "0pzmzagvrrapjsnd8xg4lqwynwnb5rcqk2n9h2kzba8p2fs13hp8";
        };
      });

    dovecot = prev.dovecot.overrideAttrs (oldAttrs: {
      configureFlags = oldAttrs.configureFlags ++ [ "--with-solr" ];
      buildInputs = oldAttrs.buildInputs ++ [ prev.expat ];
    });

    postgresql_11_gssapi = prev.postgresql_11.overrideAttrs (oldAttrs: rec {
      configureFlags = oldAttrs.configureFlags ++ [ "--with-gssapi" ];
      buildInputs = oldAttrs.buildInputs ++ [ prev.krb5 ];
    });

    postgresql_12_gssapi = prev.postgresql_12.overrideAttrs (oldAttrs: rec {
      configureFlags = oldAttrs.configureFlags ++ [ "--with-gssapi" ];
      buildInputs = oldAttrs.buildInputs ++ [ prev.krb5 ];
    });

    postgresql_15_gssapi = prev.postgresql_15.overrideAttrs (oldAttrs: rec {
      configureFlags = oldAttrs.configureFlags ++ [ "--with-gssapi" ];
      buildInputs = oldAttrs.buildInputs ++ [ prev.krb5 ];
    });

    opencv-java = prev.opencv3.overrideAttrs (oldAttrs: rec {
      pname = "opencv-java";
      nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ prev.jdk11 prev.ant ];
      cmakeFlags = oldAttrs.cmakeFlags ++ [ "-DWITH_JAVA=ON" ];
    });

    lispPackages = prev.lispPackages // localLispPackages // {
      cl_plus_ssl = unstable.lispPackages.cl_plus_ssl;
    };

    localLispPackages = (callPackage ./pkgs/lisp { inherit localLispPackages; })
      // prev.lispPackages;

    hll2380dw-cups = callPackage ./pkgs/hll2380dw-cups.nix { };

    hll2380dw-lpr = callPackage ./pkgs/hll2380dw-lp.nix { };

    cl-gemini = callPackage ./pkgs/cl-gemini.nix { inherit localLispPackages; };

    fudo-service = callPackage ./pkgs/fudo-service.nix { };

    vanilla-forum = callPackage ./vanilla-forum.nix { };

    openttd-data = fetchgit {
      url = "https://git.fudo.org/fudo-public/openttd-data.git";
      rev = "5b7dd0ca9014e642e1f2d0aa3154b5da869911d3";
      sha256 = "061k0f0jgm5k81djslb172xk0wkis0m878izgisyj2qgg3wf1awh";
    };

    clj2nix = fetchFromGitHub {
      owner = "hlolli";
      repo = "clj2nix";
      rev = "3d0a38c954c8e0926f57de1d80d357df05fc2f94";
      sha256 = "0y77b988qdgsrp4w72v1f5rrh33awbps2qdgp2wr2nmmi44541w5";
    };

    signal-desktop = prev.signal-desktop.overrideAttrs (oldAttrs: rec {
      version = "6.39.0";
      src = fetchurl {
        url =
          "https://updates.signal.org/desktop/apt/pool/s/signal-desktop/signal-desktop_${version}_amd64.deb";
        sha256 = "0bvz50z3cpqgs9w4x6g53qw78d8l3k1s89039rd6ixvid8aijvvh";
      };
    });

    lz4json = callPackage ./pkgs/lz4json.nix { };

    discourse-fudo = prev.discourse.overrideAttrs (oldAttrs: rec {
      version = "2.8.0-beta10";
      src = prev.fetchFromGitHub {
        owner = "discourse";
        repo = "discourse";
        rev = "v${version}";
        sha256 = "sha256-11fiwf0wzq93isfqcbxp6rpxajavqiayg9gka7nmzqn6as613qa8";
      };
    });

    # Heimdal fails when not building against openssl 1.1...
    heimdal = prev.heimdal.override { openssl = prev.openssl_1_1; };

    kdcMergePrincipals = helpers.lib.writeRubyApplication {
      name = "kdc-merge-principals";
      pkgs = prev;
      runtimeInputs = [ heimdal ];
      text = readFile ./static/kdc-merge-principals.rb;
    };

    generateHostSshKeys = helpers.lib.writeRubyApplication {
      name = "generate-host-ssh-keys";
      pkgs = prev;
      runtimeInputs = [ prev.openssh ];
      text = readFile ./static/generate-host-ssh-keys.rb;
    };

    initializeKerberosRealm = helpers.lib.writeRubyApplication {
      name = "initialize-kerberos-realm";
      pkgs = prev;
      runtimeInputs = [ heimdal ];
      text = readFile ./static/initialize-kerberos-realm.rb;
    };

    instantiateKerberosRealm = helpers.lib.writeRubyApplication {
      name = "instantiate-kerberos-realm";
      pkgs = prev;
      runtimeInputs = [ heimdal ];
      text = readFile ./static/instantiate-kerberos-realm.rb;
    };

    addHostToKerberosRealm = helpers.lib.writeRubyApplication {
      name = "add-host-to-kerberos-realm";
      pkgs = prev;
      runtimeInputs = [ heimdal ];
      text = readFile ./static/add-host-to-kerberos-realm.rb;
    };

    extractKerberosHostKeytab = helpers.lib.writeRubyApplication {
      name = "extract-kerberos-host-keytab";
      pkgs = prev;
      runtimeInputs = [ heimdal ];
      text = readFile ./static/extract-kerberos-host-keytab.rb;
    };

    extractKerberosKeytab = helpers.lib.writeRubyApplication {
      name = "extract-kerberos-keytab";
      pkgs = prev;
      runtimeInputs = [ heimdal ];
      text = readFile ./static/extract-kerberos-keytab.rb;
    };

    kdcConvertDatabase = helpers.lib.writeRubyApplication {
      name = "kdc-convert-database";
      pkgs = prev;
      runtimeInputs = [ heimdal ];
      text = readFile ./static/kdc-convert-database.rb;
    };

    kdcAddPrincipal = helpers.lib.writeRubyApplication {
      name = "kdc-add-principal";
      pkgs = prev;
      runtimeInputs = [ heimdal ];
      text = readFile ./static/kdc-add-principal.rb;
    };

    nsdRotateKeys = helpers.lib.writeRubyApplication {
      name = "nsd-rotate-keys";
      pkgs = prev;
      runtimeInputs = with prev; [ ldns.examples ];
      libInputs = [ ./static ];
      text = readFile ./static/nsd-rotate-keys.rb;
    };

    nsdSignZone = helpers.lib.writeRubyApplication {
      name = "nsd-sign-zone";
      pkgs = prev;
      runtimeInputs = with prev; [ ldns.examples ];
      libInputs = [ ./static ];
      text = readFile ./static/nsd-sign-zone.rb;
    };

    youtube-dl = unstable.youtube-dl;

    google-photo-uploader =
      google-photo-uploader.packages."${system}".google-photo-uploader;
  })
