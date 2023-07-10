{ lib, stdenv, fetchurl, bash, jre, version, sha256 }:

stdenv.mkDerivation rec {
  pname = "papermc-current";
  inherit version;

  jar = let
    mcVersion = lib.versions.pad 3 version;
    buildNum = builtins.elemAt (lib.versions.splitVersion version) 3;
  in fetchurl {
    url =
      "https://papermc.io/api/v2/projects/paper/versions/${mcVersion}/builds/${buildNum}/downloads/paper-${mcVersion}-${buildNum}.jar";
    inherit sha256;
  };

  preferLocalBuild = true;

  dontUnpack = true;
  dontConfigure = true;

  buildPhase = ''
    cat > minecraft-server << EOF
    #!${bash}/bin/sh
    exec ${jre}/bin/java \$@ -jar $out/share/papermc/papermc.jar nogui
  '';

  installPhase = ''
    install -Dm444 ${jar} $out/share/papermc/papermc.jar
    install -Dm555 -t $out/bin minecraft-server
  '';

  meta = {
    description = "High-performance Minecraft Server";
    homepage = "https://papermc.io/";
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ aaronjanse neonfuz ];
    mainProgram = "minecraft-server";
  };
}
