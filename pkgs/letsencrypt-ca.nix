{ stdenv, fetchurl }:

let
  url = "https://letsencrypt.org/certs/isrg-root-x1-cross-signed.pem";
  sha256 = "13526i3sjfhp6qqz7p7zil6r6a8knbgkhi9985863p4y68j1rk4m";
  # sha256 = "1y00zqcrczsrv4403785df2b7q2hz4cf5z1kwlc58pd1g4gifc3a";

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
    homepage = "https://letsencrypt.com/certificates";
    description = "Certificate Authority (CA) certificate for LetsEncrypt";
  };
}
