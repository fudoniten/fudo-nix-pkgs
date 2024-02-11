{ lib, buildNpmPackage, fetchFromGitHub, ... }:

buildNpmPackage rec {
  pname = "immich-cli";
  version = "1.94.1";

  src = fetchFromGitHub {
    owner = "immich-app";
    repo = "immich";
    rev = "v${version}";
    hash = "sha256-U1QftTpUOvel2Szt4yXZd04RpyyaAqanBIrQ727p54A=";
  };

  npmDepsHash = "sha256-a9ehls05ov98FUg8mw0MlAV05ori3CEwGLiODndGmoQ=";

  npmWorkspace = "@immich/cli";

  meta = {
    changelog = "https://github.com/immich-app/immich/releases/tag/${src.rev}";
    description = "CLI utilities for Immich to help upload images and videos";
    homepage = "https://github.com/immich-app/immich";
    license = lib.licenses.mit;
    mainProgram = "immich";
  };
}
