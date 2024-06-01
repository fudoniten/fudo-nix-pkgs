{
  description = "Fudo packages";

  inputs = {
    google-photo-uploader-flake.url =
      "git+https://fudo.dev/public/google-photo-uploader.git";
    helpers.url = "git+https://fudo.dev/public/nix-helpers.git";
    nixpkgs.url = "nixpkgs/nixos-23.11";
    unstableNixpkgs.url = "nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";

    lisp-packages.url = "git+https://fudo.dev/public/lisp-repository.git";
  };

  outputs = { self, nixpkgs, unstableNixpkgs, lisp-packages, helpers, utils, ...
    }@inputs:
    (utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        localLispPackages = lisp-packages.packages."${system}";
      in { packages = pkgs.callPackage ./pkgs.nix { inherit inputs; }; }))

    //

    {
      overlays = rec {
        packages =
          (final: prev: prev.callPackage ./pkgs.nix { inherit inputs; });
        default = packages;
      };

      nixosModules.default = { ... }: {
        config.nixpkgs.overlays = [ self.overlays.default ];
      };
    };
}
