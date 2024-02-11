{ lib, buildNpmPackage, fetchFromGitHub, jq, ... }:

let
  version = "1.94.1";

  immichSrc = fetchFromGitHub {
    owner = "immich-app";
    repo = "immich";
    rev = "v${version}";
    hash = "sha256-U1QftTpUOvel2Szt4yXZd04RpyyaAqanBIrQ727p54A=";
  };

  # sdkDir = "${immichSrc}/open-api/typescript-sdk";

in buildNpmPackage rec {
  pname = "immich-cli";
  inherit version;

  src = "${immichSrc}";

  sourceRoot = "source/cli";

  npmDepsHash = "sha256-a9ehls05ov98FUg8mw0MlAV05ori3CEwGLiODndGmoQ=";

  # postPatch = ''
  #   PKGDATA=$(${jq}/bin/jq '.packages."../open-api/typescript-sdk"' ./package-lock.json)
  #   cat ${immichSrc}/cli/package-lock.json |
  #     ${jq}/bin/jq '.packages."".dependencies."@immich/sdk" = "file:${sdkDir}"' |
  #     ${jq}/bin/jq '.packages."node_modules/@immich/sdk.resolved" = "file:${sdkDir}"' |
  #     ${jq}/bin/jq '.dependencies."@immich/sdk".version = "file:${sdkDir}"' |
  #     ${jq}/bin/jq --arg PKGDATA="$PKGDATA" '.packages."${sdkDir}" = $PKGDATA"' > ./package-lock.json
  #   ${jq}/bin/jq '.dependencies."@immich/sdk" = "${immichSrc}/open-api/typescript-sdk"' ${immichSrc}/cli/package.json > ./package.json
  # '';

  meta = {
    changelog = "https://github.com/immich-app/immich/releases/tag/${src.rev}";
    description = "CLI utilities for Immich to help upload images and videos";
    homepage = "https://github.com/immich-app/immich";
    license = lib.licenses.mit;
    mainProgram = "immich";
  };
}
