{ lib, stdenv, fetchurl, autoPatchelfHook, src }:

let
  version = (lib.importJSON "${src}/packages/coding-agent/package.json").version;

  binaries = {
    "x86_64-linux" = {
      url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/omp-linux-x64";
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };
    "aarch64-linux" = {
      url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/omp-linux-arm64";
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };
    "x86_64-darwin" = {
      url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/omp-darwin-x64";
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };
    "aarch64-darwin" = {
      url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/omp-darwin-arm64";
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };
  };

  binary = binaries.${stdenv.hostPlatform.system}
    or (throw "oh-my-pi: unsupported platform ${stdenv.hostPlatform.system}");
in stdenv.mkDerivation {
  pname = "oh-my-pi";
  inherit version;

  src = fetchurl { inherit (binary) url hash; };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  # Patch glibc/libstdc++ references in the Bun-compiled binary
  nativeBuildInputs = [ autoPatchelfHook ];

  installPhase = ''
    mkdir -p $out/bin
    install -m755 $src $out/bin/omp
  '';

  meta = with lib; {
    description = "AI coding agent for the terminal";
    homepage = "https://omp.sh";
    license = licenses.mit;
    platforms = builtins.attrNames binaries;
    mainProgram = "omp";
  };
}
