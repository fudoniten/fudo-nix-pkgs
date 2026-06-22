{
  description = "Fudo packages";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    google-photo-uploader-flake.url = "github:fudoniten/google-photo-uploader";
    helpers.url = "github:fudoniten/fudo-nix-helpers";
    unstableNixpkgs.url = "nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    oh-my-pi.url = "github:can1357/oh-my-pi";
    oh-my-pi.flake = false;
  };

  outputs = { self, nixpkgs, unstableNixpkgs, helpers, utils, ... }@inputs:
    (utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          # permittedInsecurePackages = [ "openssl-1.1.1w" ];
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
              postgresql_17_gssapi hll2380dw-cups hll2380dw-lpr openttd-data
              lz4json kdcMergePrincipals generateHostSshKeys
              initializeKerberosRealm instantiateKerberosRealm
              addHostToKerberosRealm extractKerberosHostKeytab
              extractKerberosKeytab kdcConvertDatabase kdcAddPrincipal
              nsdRotateKeys nsdSignZone google-photo-uploader immich-cli
              tesla-auth waylandcraft oh-my-pi;
          };
      };

      nixosModules.default = { ... }: {
        config.nixpkgs.overlays = [ self.overlays.default ];
      };
    };
}
