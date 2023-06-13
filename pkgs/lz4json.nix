{ pkg-config, lz4, fetchFromGitHub, stdenv, ... }:

stdenv.mkDerivation rec {
  pname = "lz4json";
  version = "v2";

  src = fetchFromGitHub {
    owner = "andikleen";
    repo = "lz4json";
    rev = "${version}";
    sha256 = "A8pYjJ+1e3BmqnSPHV1WL37Wru7VyFXzNRJJk79Htvc=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ lz4.dev ];

  installPhase = ''
    mkdir -p $out/bin
    mv lz4json $out/bin
  '';
}
