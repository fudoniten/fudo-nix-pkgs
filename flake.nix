{
  description = "Fudo packages";

  inputs = {
    unstableNixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = { self, unstableNixpkgs, ... }: {
    overlay = import ./overlay.nix { inherit unstableNixpkgs; };
  };
}
