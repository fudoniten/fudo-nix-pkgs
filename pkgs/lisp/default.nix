{ pkgs, localLispPackages, ... }:

rec {
  agnostic-lizard = import ./agnostic-lizard.nix { inherit pkgs localLispPackages; };
  arrows  = import ./arrows.nix { inherit pkgs localLispPackages; };
  cl-gemini = import ./cl-gemini.nix { inherit pkgs localLispPackages; };
  cl-sasl = import ./cl-sasl.nix { inherit pkgs localLispPackages; };
  cl-xmpp = import ./cl-xmpp.nix { inherit pkgs localLispPackages; };
  backplane-dns = import ./backplane-dns.nix { inherit pkgs localLispPackages; };
  backplane-server = import ./backplane-server.nix { inherit pkgs localLispPackages; };
  fare-mop = import ./fare-mop.nix { inherit pkgs localLispPackages; };
  file-types = import ./file-types.nix { inherit pkgs localLispPackages; };
  inferior-shell = import ./inferior-shell.nix { inherit pkgs localLispPackages; };
  ip-utils = import ./ip-utils.nix { inherit pkgs localLispPackages; };
  osicat = import ./osicat.nix { inherit pkgs localLispPackages; };
  slynk = import ./slynk.nix { inherit pkgs localLispPackages; };
  slynk-asdf = import ./slynk-asdf.nix { inherit pkgs localLispPackages; };
  slynk-macrostep = import ./slynk-macrostep.nix { inherit pkgs localLispPackages; };
  slynk-stepper = import ./slynk-stepper.nix { inherit pkgs localLispPackages; };
  usocket-server = import ./usocket-server.nix { inherit pkgs localLispPackages; };
  xml-emitter = import ./xml-emitter.nix { inherit pkgs localLispPackages; };
}
