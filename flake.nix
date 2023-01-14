{
  description = "Fudo packages";

  inputs = {
    helpers.url = "git+https://git.fudo.org/fudo-public/nix-helpers.git";
  };

  outputs = { self, helpers, ... }: {
    overlays = rec {
      pkgs = import ./overlay.nix { inherit helpers; };
      default = pkgs;
    };
  };
}
