{ stdenv, fetchgit, pkgs, bundlerEnv }:

let
  version = "0.1";
  srcdir = pkgs.fetchgit {
    url = "https://git.fudo.org/fudo-public/backplane-client.git";
    rev = "c946a155b73e2adf2de3efbe8e9c97deb8682a5f";
    sha256 = "1siii5f07j4k3ly3wfbxb8j5pd6n01chwyyra7sgihyi0yhd2lx2";
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
