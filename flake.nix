{
  description = "Fudo packages";

  inputs = {
    backplane-client.url =
      "git+https://git.fudo.org/fudo-public/backplane-client.git?ref=dev";
    helpers.url = "git+https://git.fudo.org/fudo-public/nix-helpers.git";
    unstableNixpkgs = "nixpkgs/nixos-unstable";
  };

  outputs = { self, backplane-client, helpers, unstableNixpkgs, ... }@inputs: {
    overlays = rec {
      packages = import ./overlay.nix inputs;
      default = packages;
    };
    nixosModules.default = { ... }: {
      config.nixpkgs.overlays = self.overlays.default;
    };
  };
}
