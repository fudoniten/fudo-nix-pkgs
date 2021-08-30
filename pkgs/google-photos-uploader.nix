{ config, lib, pkgs, ... }:

pkgs.buildGoModule rec {
  pname = "google-photos-uploader";
  version = "1.6.1";

  src = pkgs.fetchFromGitHub {
    owner = "int128";
    repo = "gpup";
    rev = "${version}";
    sha256 = "0zdkd5iwkp270p0810dijg25djkzrsdyqiqaqv6rzzgzj5d5pwhm";
  };

  modSha256 = "15ndc6jq51f9mz1v089416x2lxrifp3wglbxpff8b055jj07hbkw";

  subPackages = [ "." ];

  meta = with pkgs.lib; {
    description = "Google photos uploader, written in Go.";
    homepage = "https://github.com/int128/gpup";
    license = licenses.asl20;
    platforms = platforms.linux ++ platforms.darwin;
  };  
}
