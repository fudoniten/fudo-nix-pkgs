{ stdenv, fetchurl }:

let
  url = "https://letsencrypt.org/certs/letsencryptauthorityx3.pem.txt";
  sha256 = "b6dd03f7fb8508e4f7ffe82ca8a3f98dde163e0bd44897e112a0850a5b606acf";

in stdenv.mkDerivation {

  name = "letsencrypt-ca-pem";

  src = fetchurl {
    name = "isrgrootx1.pem.txt";
    url = url;
    sha256 = sha256;
  };

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -pv $out
    cp -v $src $out/ca.pem
  '';

  meta = {
    homepage = https://letsencrypt.com/certificates;
    description = "Certificate Authority (CA) certificate for LetsEncrypt";
  };
}
