{
  description = "Fudo packages";

  inputs = {
    helpers.url = "git+https://git.fudo.org/fudo-public/nix-helpers.git";
    unstableNixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = { self, helpers, unstableNixpkgs, ... }@inputs: {
    overlays = rec {
      packages = import ./overlay.nix inputs;
      default = packages;
    };
    nixosModules.default = { ... }: {
      config.nixpkgs.overlays = [ self.overlays.default ];
    };
  };
}
