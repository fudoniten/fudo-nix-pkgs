{ stdenv, lib, fetchurl, makeWrapper, cups, dpkg, a2ps, ghostscript, gnugrep
, gnused, coreutils, file, perl, which }:

stdenv.mkDerivation rec {
  pname = "hll2380dw-cups";
  version = "3.2.0-1";
  platform = "i386";

  src = fetchurl {
    url =
      "https://download.brother.com/welcome/dlf101772/hll2380dwcupswrapper-${version}.i386.deb";
    sha256 = "08g3kx5lgwzb3f9ypj8knmpkkj0h3kv1i4gd20rzjxrx6vx1wbpl";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ cups ghostscript dpkg a2ps ];

  dontUnpack = true;

  installPhase = ''
    dpkg-deb -x $src $out
      wrapProgram $out/opt/brother/Printers/HLL2380DW/cupswrapper/paperconfigml1 \
        --prefix PATH : ${
          lib.makeBinPath [ coreutils ghostscript gnugrep gnused ]
        }
    mkdir -p $out/lib/cups/filter/
    ln -s $out/opt/brother/Printers/HLL2380DW/cupswrapper/brother_lpdwrapper_HLL2380DW \
        $out/lib/cups/filter/brother_lpdwrapper_HLL2380DW
    ln -s $out/opt/brother/Printers/HLL2380DW/paperconfigml1 \
        $out/lib/cups/filter/
    mkdir -p $out/share/cups/model
    ln -s $out/opt/brother/Printers/HLL2380DW/cupswrapper/brother-HLL2380DW-cups-en.ppd $out/share/cups/model/
    touch $out/HI
  '';

  meta = with lib; {
    homepage = "http://www.brother.com/";
    description = "Brother HL-L2380DW combined print driver";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    downloadPage =
      "http://support.brother.com/g/b/downloadlist.aspx?c=us_ot&lang=en&prod=hll2380dw_us&os=128";
  };
}
