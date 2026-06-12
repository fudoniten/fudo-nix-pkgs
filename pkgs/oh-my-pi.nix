{ lib, stdenv, bun, cargo, rustPlatform, pkg-config, openssl, src }:

let
  version = (lib.importJSON "${src}/package.json").version;
in stdenv.mkDerivation {
  pname = "oh-my-pi";
  inherit version src;

  nativeBuildInputs = [ bun pkg-config cargo ];
  buildInputs = [ openssl ];

  # Bun needs a writable home for its cache
  preBuild = ''
    export HOME=$(mktemp -d)
    export BUN_INSTALL_CACHE_DIR=$(mktemp -d)
  '';

  buildPhase = ''
    runHook preBuild
    bun install --frozen-lockfile
    bun run --cwd packages/coding-agent build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    # bun --compile outputs to packages/coding-agent/omp (or dist/omp)
    install -m755 \
      $(find packages/coding-agent -maxdepth 2 -name 'omp' -type f | head -1) \
      $out/bin/omp
    runHook postInstall
  '';

  meta = with lib; {
    description = "AI coding agent for the terminal (omp)";
    homepage = "https://omp.sh";
    license = licenses.mit;
    platforms = platforms.linux ++ platforms.darwin;
    mainProgram = "omp";
  };
}
