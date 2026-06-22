{ lib, rustPlatform, fetchFromGitHub, pkg-config, openssl, webkitgtk_4_1, gtk3
, libxdo, glib, cairo, pango, gdk-pixbuf, atk, ... }:

rustPlatform.buildRustPackage rec {
  pname = "tesla-auth";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "adriankumpf";
    repo = "tesla_auth";
    rev = "v${version}";
    hash = lib.fakeHash;
  };

  cargoHash = lib.fakeHash;

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl webkitgtk_4_1 gtk3 libxdo glib cairo pango gdk-pixbuf atk ];

  meta = with lib; {
    description = "Securely generate API tokens for third-party access to your Tesla";
    homepage = "https://github.com/adriankumpf/tesla_auth";
    license = licenses.mit;
    mainProgram = "tesla_auth";
  };
}
