{ stdenv, fetchurl }:

let
  url = "https://letsencrypt.org/certs/letsencryptauthorityx3.pem.txt";
  sha256 = "100lxxvqv4fj563bm03zzk5r36hq5jx9nnrajzs38g825c5k0cg2";

in stdenv.mkDerivation {

  name = "letsencrypt-ca-pem";

  src = fetchurl {
    name = "letsencryptauthorityx3.pem.txt";
    url = url;
    sha256 = sha256;
  };

  phases = [ "installPhase" ];

  installPhase = ''
    cp -v $src $out
  '';

  meta = {
    homepage = https://letsencrypt.com/certificates;
    description = "Certificate Authority (CA) certificate for LetsEncrypt";
  };
}
