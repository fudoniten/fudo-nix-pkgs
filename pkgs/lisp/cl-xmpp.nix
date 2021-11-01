{ pkgs, localLispPackages, ... }:

pkgs.lispPackages.buildLispPackage {
  baseName = "cl-xmpp";
  packageName = "cl-xmpp";
  description = "XMPP library for Common Lisp";

  buildSystems = [
    "cl-xmpp"
    "cl-xmpp-sasl"
    "cl-xmpp-tls"
  ];

  deps = with localLispPackages; [
    cl-base64
    cl_plus_ssl
    cl-sasl
    cxml
    ironclad
    usocket
  ];

  src = pkgs.fetchFromGitHub {
    owner  = "j4yk";
    repo   = "cl-xmpp";
    rev    = "a0f206e583c72d80523bdf108e7d507597555c6d";
    sha256 = "16qwm7yvwi73q07rsg0i5wrxbv44wm75m3710ph0vf1lzdkrsizk";
  };

  asdFilesToKeep = [
    "cl-xmpp.asd"
    "cl-xmpp-sasl.asd"
    "cl-xmpp-tls.asd"
  ];
}
