{ pkgs, localLispPackages, ... }:

with pkgs.lib;
let
  version = "20211031";

  server-launcher = pkgs.writeText "launch-cl-gemini.lisp" ''
    (defun getenv-or-fail (env-var &optional default)
      (let ((value (uiop:getenv env-var)))
        (if (null value)
            (if default
                default
                (uiop:die 1 "unable to find required env var: ~A" env-var))
            value)))

    (require :asdf)
    (asdf:load-system :slynk)
    (asdf:load-system :cl-gemini)
    (let ((slynk-port (uiop:getenvp "GEMINI_SLYNK_PORT")))
      (when slynk-port
        (slynk:create-server :port (parse-integer slynk-port) :dont-close t)))
    (let ((feed-file (uiop:getenvp "GEMINI_FEEDS")))
      (when feed-file
        (load feed-file)))
    (cl-gemini:start-gemini-server
      (getenv-or-fail "GEMINI_LISTEN_IP")
      (getenv-or-fail "GEMINI_PRIVATE_KEY")
      (getenv-or-fail "GEMINI_CERTIFICATE")
      :port (parse-integer (getenv-or-fail "GEMINI_LISTEN_PORT"))
      :document-root (getenv-or-fail "GEMINI_DOCUMENT_ROOT")
      :textfiles-root (getenv-or-fail "GEMINI_TEXTFILES_ROOT")
      :log-stream *standard-output*
      :threaded t
      :separate-thread t)
    (loop (sleep 10))
  '';

  server-wrapper = pkgs.writeShellScript "launch-server.sh" ''
    ${pkgs.lispPackages.clwrapper}/bin/common-lisp.sh --load ${server-launcher}
  '';

  sbcl-with-ssl = pkgs.sbcl.overrideAttrs (oldAttrs: rec {
    buildInputs = oldAttrs.buildInputs ++ [ pkgs.openssl_1_1.dev ];
  });

in pkgs.stdenv.mkDerivation {
  name = "cl-gemini-${version}";

  propagatedBuildInputs = with pkgs; [
    asdf
    sbcl-with-ssl
    localLispPackages.cl-gemini
  ];

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    cp "${server-wrapper}" "$out/bin/launch-server.sh"
  '';
}
