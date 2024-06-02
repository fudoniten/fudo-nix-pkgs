{
  description = "Fudo packages";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
    google-photo-uploader-flake.url =
      "git+https://fudo.dev/public/google-photo-uploader.git";
    helpers.url = "git+https://fudo.dev/public/nix-helpers.git";
    unstableNixpkgs.url = "nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";

    lisp-packages.url = "git+https://fudo.dev/public/lisp-repository.git";
  };

  outputs = { self, nixpkgs, unstableNixpkgs, lisp-packages, helpers, utils, ...
    }@inputs:
    (utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          permittedInsecurePackages = [ "openssl-1.1.1w" ];
          config.allowUnfree = true;
        };
        unstable = import unstableNixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in {
        packages =
          pkgs.callPackage ./pkgs.nix { inherit inputs pkgs unstable; };
      }))

    //

    {
      overlays = rec {
        default = packages;
        packages = final: prev:
          let localPackages = self.packages."${prev.system}";
          in {
            inherit (localPackages)
              letsencrypt-ca papermc-current minecraft-current dovecot heimdal
              postgresql_11_gssapi postgresql_12_gssapi postgresql_15_gssapi
              hll2380dw-cups hll2380dw-lpr openttd-data signal-desktop lz4json
              kdcMergePrincipals generateHostSshKeys initializeKerberosRealm
              instantiateKerberosRealm addHostToKerberosRealm
              extractKerberosHostKeytab extractKerberosKeytab kdcConvertDatabase
              kdcAddPrincipal nsdRotateKeys nsdSignZone google-photo-uploader
              immich-cli;
          };
      };

      nixosModules.default = { ... }: {
        config.nixpkgs.overlays = [ self.overlays.default ];
      };
    };
}
