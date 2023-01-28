{
  description = "Fudo packages";

  inputs = {
    helpers.url = "git+https://git.fudo.org/fudo-public/nix-helpers.git";
    backplane-client.url =
      "git+https://git.fudo.org/fudo-public/backplane-client.git?ref=dev";
  };

  outputs = { self, backplane-client, helpers, ... }: {
    overlays = rec {
      pkgs = final: prev:
        import ./overlay.nix { inherit helpers; } // {
          inherit (backplane-client.packages."${prev.system}")
            backplaneDnsClient;
        };
      default = pkgs;
    };
  };
}
