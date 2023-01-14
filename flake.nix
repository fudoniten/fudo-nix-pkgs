{
  description = "Fudo packages";

  inputs = {
    helpers.url = "git+https://git.fudo.org/fudo-public/nix-helpers.git";
  };

  outputs = { self, helpers, ... }: {
    overlay = import ./overlay.nix { inherit helpers; };
  };
}
