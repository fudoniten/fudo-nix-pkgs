{ pkgs, localLispPackages, ... }:

with pkgs.lib;
let
  launcher = pkgs.writeText "launch-backplane-dns.lisp" ''
    (require :asdf)
    (asdf:load-system :backplane-dns)
    (backplane-dns:start-listener-with-env)
    (loop (sleep 600))
  '';

  launcherScript = pkgs.writeShellScriptBin "launch-backplane-dns.sh" ''
    ${pkgs.lispPackages.clwrapper}/bin/common-lisp.sh --load ${launcher}
  '';

in pkgs.stdenv.mkDerivation {
  pname = "backplane-dns-server";
  version = "0.1.0";

  propagatedBuildInputs = with pkgs; [
    asdf
    sbcl
    lispPackages.clwrapper
    localLispPackages.backplane-dns
  ];

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p "$out/bin"
    cp ${launcherScript}/bin/launch-backplane-dns.sh "$out/bin"
  '';
}
