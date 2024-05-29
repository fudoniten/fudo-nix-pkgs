{
  description = "Fudo packages";

  inputs = {
    google-photo-uploader-flake.url =
      "git+https://fudo.dev/public/google-photo-uploader.git";
    helpers.url = "git+https://fudo.dev/public/nix-helpers.git";
    nixpkgs.url = "nixpkgs/nixos-23.11";
    unstableNixpkgs.url = "nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, unstableNixpkgs, helpers, utils, ... }@inputs:
    (utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in { packages = import ./pkgs.nix inputs pkgs; }))

    //

    {
      overlays = rec {
        packages = (final: prev:
          let unstable = import unstableNixpkgs { inherit (prev) system; };
          in self.packages."${prev.system}" // {
            immich-cli = unstable.immich-cli;
          });
        default = packages;
      };

      nixosModules.default = { ... }: {
        config.nixpkgs.overlays = [ self.overlays.default ];
      };
    };
}
