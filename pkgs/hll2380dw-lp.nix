{ lib, stdenv, fetchurl, makeWrapper, cups, dpkg, a2ps, ghostscript, gnugrep
, gnused, coreutils, file, perl, which }:

let
  model = "hll2380dw";
  version = "3.2.0-1";
  src = fetchurl {
    url =
      "https://download.brother.com/welcome/dlf101771/hll2380dwlpr-${version}.i386.deb";
    sha256 = "08g3kx5lgwzb3f9ypj8knmpkkj0h3kv1i4gd20rzjxrx6vx1wbpx";
  };
  reldir = "opt/brother/Printers/${model}/";

in stdenv.mkDerivation rec {
  inherit src version;
  pname = "${model}-lpr";

  nativeBuildInputs = [ dpkg makeWrapper ];

  unpackPhase = "dpkg-deb -x $src $out";

  installPhase = ''
    DIR="$out/${reldir}"
    substituteInPlace $dir/lpd/filter_${model} \
      --replace /usr/bin/perl ${perl}/bin/perl \
      --replace "BR_PRT_PATH =~" "BR_PRT_PATH = \"$dir\"; #" \
      --replace "PRINTER =~" "PRINTER = \"${model}\"; #"
    wrapProgram $dir/lpd/filter_${model} \
      --prefix PATH : ${
        lib.makeBinPath [ coreutils ghostscript gnugrep gnused which ]
      }
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      $dir/lpd/${model}filter
  '';

  meta = {
    homepage = "http://www.brother.com/";
    description = "Brother ${lib.toUpper model} LPR print driver";
    license = lib.licenses.unfree;
    platforms = [ "i386" "x86_64-linux" ];
    downloadPage =
      "http://support.brother.com/g/b/downloadlist.aspx?c=us_ot&lang=en&prod=hll2380dw_us&os=128";
  };
}
