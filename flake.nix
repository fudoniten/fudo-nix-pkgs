{
  description = "Fudo packages";

  inputs = {
    helpers.url = "git+https://git.fudo.org/fudo-public/nix-helpers.git";
    backplane-client.url =
      "git+https://git.fudo.org/fudo-public/backplane-client.git?ref=dev";
  };

  outputs = { self, backplane-client, helpers, ... }@inputs: {
    overlays = rec {
      packages = import ./overlay.nix inputs;
      default = packages;
    };
  };
}
