{ pkgs, lib, fetchurl, ... }:

let
  version = "2.2.5";
  url =
    "https://mirrors.sonic.net/apache/archiva/${version}/binaries/apache-archiva-${version}-bin.tar.gz";
  sha256 = "01119af2d9950eacbcce0b7f8db5067b166ad26c1e1701bef829105441bb6e29";

in pkgs.stdenv.mkDerivation {
  name = "archiva-${version}";

  src = builtins.fetchurl {
    url = url;
    sha256 = sha256;
  };

  phases = [ "installPhase" ];

  buildInputs = with pkgs; [ stdenv procps makeWrapper ];

  installPhase = ''
    mkdir $out
    tar -xzf $src
    cd apache-archiva-${version}
    mv {LICENSE,NOTICE,apps,bin,conf,contexts,lib,logs,temp} $out
    makeWrapper $out/bin/archiva $out/bin/archivaWrapped --set PATH ${
      lib.makeBinPath [ pkgs.procps ]
    }
  '';
}
