{
  description = "Fudo packages";

  inputs = {
    google-photo-uploader-flake.url =
      "git+https://fudo.dev/public/google-photo-uploader.git";
    helpers.url = "git+https://fudo.dev/public/nix-helpers.git";
    unstableNixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = { self, ... }@inputs: {
    overlays = rec {
      packages = import ./overlay.nix inputs;
      default = packages;
    };
    nixosModules.default = { ... }: {
      config.nixpkgs.overlays = [ self.overlays.default ];
    };
  };
}
