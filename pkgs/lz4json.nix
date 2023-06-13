{ lz4, fetchFromGitHub, stdenv, ... }:

stdenv.mkDerivation rec {
  pname = "lz4json";
  version = "v2";

  src = fetchFromGitHub {
    owner = "andikleen";
    repo = "lz4json";
    rev = "${version}";
    sha256 = "";
  };

  buildInputs = [ lz4.dev ];
}
