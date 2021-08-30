{ stdenv, fetchgit, pkgs, bundlerEnv }:

let
  url = "https://git.fudo.org/fudo-public/backplane-dns-client.git";
  version = "0.1";
  srcdir = ../static/backplane-dns-client;
  gems = bundlerEnv {
    name = "backplane-dns-client-env";
    ruby = pkgs.ruby;
    gemdir = srcdir;
  };

in stdenv.mkDerivation {
  name = "backplane-dns-client-${version}";

  src = srcdir;

  buildInputs = [gems pkgs.ruby];

  phases = ["installPhase"];

  installPhase = ''
    mkdir -p "$out/bin" "$out/lib"

    cp "$src/dns-client.rb" "$out/lib"

    BIN="$out/bin/backplane-dns-client"

    cat > $BIN <<EOF
#!${pkgs.bash}/bin/bash -e
exec ${gems}/bin/bundle exec ${pkgs.ruby}/bin/ruby $out/lib/dns-client.rb "\$@"
EOF
    chmod +x $BIN
  '';
}
