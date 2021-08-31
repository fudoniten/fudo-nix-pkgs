{ stdenv, fetchgit, pkgs, bundlerEnv }:

let
  version = "0.1";
  srcdir = pkgs.fetchgit {
    url = "https://git.fudo.org/fudo-public/backplane-client.git";
    rev = "7b29ab82b124b52e24d56c67c3687a5958ac88dd";
    sha256 = "0amnjaml1a1i6civc1m9h4pd1zdskdv1fc2m9zkld97fs02djmh5";
  };
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
