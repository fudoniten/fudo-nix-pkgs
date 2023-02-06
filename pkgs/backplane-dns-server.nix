{ pkgs, localLispPackages, ... }:

with pkgs.lib;
let
  version = "20220215";

  launcher = pkgs.writeText "launch-backplane-dns.lisp" ''
    (require :asdf)
    (asdf:load-system :backplane-dns)
    (backplane-dns:start-listener-with-env)
    (loop (sleep 600))
  '';

  launcherScript = pkgs.writeShellScriptBin "launch-backplane-dns.sh" ''
    ${pkgs.lispPackages.clwrapper}/bin/common-lisp.sh --load ${launcher}
  '';

  sbcl-with-ssl = pkgs.sbcl.overrideAttrs (oldAttrs: rec {
    buildInputs = oldAttrs.buildInputs ++ [ pkgs.openssl_1_1.dev ];
    propagatedBuildInputs = oldAttrs.buildInputs ++ [ pkgs.openssl ];
  });

in pkgs.stdenv.mkDerivation {
  pname = "backplane-dns-server";
  version = version;

  propagatedBuildInputs = with pkgs; [
    asdf
    sbcl-with-ssl
    lispPackages.clwrapper
    localLispPackages.backplane-dns
    openssl
  ];

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p "$out/bin"
    cp ${launcherScript}/bin/launch-backplane-dns.sh "$out/bin"
  '';
}
