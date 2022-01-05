{
  description = "Fudo packages";

  outputs = { self, ... }: {
    overlay = import ./overlay.nix;
  };
}
