{ inputs, callPackage, fetchgit, fetchurl, pkgs, unstable, ... }:

let
  inherit (inputs) helpers;
  inherit (builtins) readFile;

in rec {
  papermc-current = papermc-1_20_4;

  papermc-26_1_2 = callPackage ./pkgs/papermc-current.nix {
    version = "26.1.2";
    sha256 = pkgs.lib.fakeHash;
  };

  papermc-1_20_4 = callPackage ./pkgs/papermc-current.nix {
    version = "1.20.4.329";
    sha256 = "x1wQVRmq4V5XzflF+X1jcQ9cPEwh1sC/9O3WAqutGhI=";
  };

  minecraft-current = minecraft-server_26_2;

  minecraft-server_26_2 = (pkgs.minecraftServers.vanilla..override {
    jre_headless = pkgs.jdk25_headless;
  }).overrideAttrs (oldAttrs: rec {
    version = "26.2";
    src = fetchurl {
      url =
        "https://piston-data.mojang.com/v1/objects/823e2250d24b3ddac457a60c92a6a941943fcd6a/server.jar";
      sha256 = "1i9ynvmh1h46v310jmv08rz0cxrgfb1dqp8f9d5mxplqb2rdzb6d";
    };
  });

  minecraft-server_1_21 = pkgs.minecraft-server.overrideAttrs (oldAttrs: {
    version = "1.21";
    src = fetchurl {
      url =
        "https://piston-data.mojang.com/v1/objects/450698d1863ab5180c25d7c804ef0fe6369dd1ba/server.jar";
      sha256 = "0gzmpifl6l1cq11lpjd5gadw50095wgyxlm2gkpzkngrhvd98qy9";
    };
  });

  minecraft-server_1_20_4 = pkgs.minecraft-server.overrideAttrs (oldAttrs: {
    version = "1.20.4";
    src = fetchurl {
      url =
        "https://piston-data.mojang.com/v1/objects/8dd1a28015f51b1803213892b50b7b4fc76e594d/server.jar";
      sha256 = "0qykf9a3nacklqsyb30kg9m79nw462la6rf92gsdssdakprscgy0";
    };
  });

  inherit (unstable) heimdal;

  dovecot = pkgs.dovecot.overrideAttrs (oldAttrs: {
    configureFlags = oldAttrs.configureFlags ++ [ "--with-solr" ];
    buildInputs = oldAttrs.buildInputs ++ [ pkgs.expat ];
  });

  postgresql_11_gssapi = pkgs.postgresql_11.overrideAttrs (oldAttrs: {
    configureFlags = oldAttrs.configureFlags ++ [ "--with-gssapi" ];
    buildInputs = oldAttrs.buildInputs ++ [ pkgs.krb5 ];
  });

  postgresql_12_gssapi = pkgs.postgresql_12.overrideAttrs (oldAttrs: {
    configureFlags = oldAttrs.configureFlags ++ [ "--with-gssapi" ];
    buildInputs = oldAttrs.buildInputs ++ [ pkgs.krb5 ];
  });

  postgresql_15_gssapi = pkgs.postgresql_15.overrideAttrs (oldAttrs: {
    configureFlags = oldAttrs.configureFlags ++ [ "--with-gssapi" ];
    buildInputs = oldAttrs.buildInputs ++ [ pkgs.krb5 ];
  });

  postgresql_17_gssapi = pkgs.postgresql_17.overrideAttrs (oldAttrs: {
    configureFlags = oldAttrs.configureFlags ++ [ "--with-gssapi" ];
    buildInputs = oldAttrs.buildInputs ++ [ pkgs.krb5 ];
  });

  opencv-java = pkgs.opencv3.overrideAttrs (oldAttrs: {
    pname = "opencv-java";
    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ pkgs.jdk11 pkgs.ant ];
    cmakeFlags = oldAttrs.cmakeFlags ++ [ "-DWITH_JAVA=ON" ];
  });

  hll2380dw-cups = callPackage ./pkgs/hll2380dw-cups.nix { };

  hll2380dw-lpr = callPackage ./pkgs/hll2380dw-lp.nix { };

  openttd-data = fetchgit {
    url = "https://fudo.dev/public/openttd-data.git";
    rev = "5b7dd0ca9014e642e1f2d0aa3154b5da869911d3";
    sha256 = "061k0f0jgm5k81djslb172xk0wkis0m878izgisyj2qgg3wf1awh";
  };

  lz4json = callPackage ./pkgs/lz4json.nix { };

  waylandcraft = callPackage ./pkgs/waylandcraft.nix { };

  kdcMergePrincipals = helpers.lib.writeRubyApplication {
    name = "kdc-merge-principals";
    inherit pkgs;
    runtimeInputs = [ heimdal ];
    text = readFile ./static/kdc-merge-principals.rb;
  };

  generateHostSshKeys = helpers.lib.writeRubyApplication {
    name = "generate-host-ssh-keys";
    inherit pkgs;
    runtimeInputs = [ pkgs.openssh ];
    text = readFile ./static/generate-host-ssh-keys.rb;
  };

  initializeKerberosRealm = helpers.lib.writeRubyApplication {
    name = "initialize-kerberos-realm";
    inherit pkgs;
    runtimeInputs = [ heimdal ];
    text = readFile ./static/initialize-kerberos-realm.rb;
  };

  instantiateKerberosRealm = helpers.lib.writeRubyApplication {
    name = "instantiate-kerberos-realm";
    inherit pkgs;
    runtimeInputs = [ heimdal ];
    text = readFile ./static/instantiate-kerberos-realm.rb;
  };

  addHostToKerberosRealm = helpers.lib.writeRubyApplication {
    name = "add-host-to-kerberos-realm";
    inherit pkgs;
    runtimeInputs = [ heimdal ];
    text = readFile ./static/add-host-to-kerberos-realm.rb;
  };

  extractKerberosHostKeytab = helpers.lib.writeRubyApplication {
    name = "extract-kerberos-host-keytab";
    inherit pkgs;
    runtimeInputs = [ heimdal ];
    text = readFile ./static/extract-kerberos-host-keytab.rb;
  };

  extractKerberosKeytab = helpers.lib.writeRubyApplication {
    name = "extract-kerberos-keytab";
    inherit pkgs;
    runtimeInputs = [ heimdal ];
    text = readFile ./static/extract-kerberos-keytab.rb;
  };

  kdcConvertDatabase = helpers.lib.writeRubyApplication {
    name = "kdc-convert-database";
    inherit pkgs;
    runtimeInputs = [ heimdal ];
    text = readFile ./static/kdc-convert-database.rb;
  };

  kdcAddPrincipal = helpers.lib.writeRubyApplication {
    name = "kdc-add-principal";
    inherit pkgs;
    runtimeInputs = [ heimdal ];
    text = readFile ./static/kdc-add-principal.rb;
  };

  nsdRotateKeys = helpers.lib.writeRubyApplication {
    name = "nsd-rotate-keys";
    inherit pkgs;
    runtimeInputs = with pkgs; [ ldns.examples ];
    libInputs = [ ./static ];
    text = readFile ./static/nsd-rotate-keys.rb;
  };

  nsdSignZone = helpers.lib.writeRubyApplication {
    name = "nsd-sign-zone";
    inherit pkgs;
    runtimeInputs = with pkgs; [ ldns.examples coreutils ];
    libInputs = [ ./static ];
    text = readFile ./static/nsd-sign-zone.rb;
  };

  inherit (inputs.google-photo-uploader-flake.packages."${pkgs.system}")
    google-photo-uploader;

  oh-my-pi = callPackage ./pkgs/oh-my-pi.nix { src = inputs.oh-my-pi; };

  inherit (unstable) immich-cli immich-go;
}
