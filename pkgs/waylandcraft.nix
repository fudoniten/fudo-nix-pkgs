{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "waylandcraft";
  version = "1.0.1";

  jar = fetchurl {
    url =
      "https://github.com/EVV1E/waylandcraft/releases/download/v${version}/waylandcraft-${version}.jar";
    sha256 = "6B61KpgsxHvxx+n8MEek0F/FiG/8UvDmmM/ud/BrfWk=";
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    install -Dm444 ${jar} $out/share/waylandcraft/waylandcraft.jar
  '';

  meta = {
    description = "A Wayland compositor running inside Minecraft (Fabric mod)";
    longDescription = ''
      WaylandCraft implements a Wayland compositor as a Fabric mod for Minecraft
      26.1.2, allowing Linux graphical applications to run inside the game world.
      Install the JAR into your Fabric mods directory. Requires Minecraft 26.1.2
      with Fabric Loader 0.19.2+ and Fabric API 0.147.0+26.1.2.
      Linux only — the mod embeds a native libwaylandcraft.so.
    '';
    homepage = "https://github.com/EVV1E/waylandcraft";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode binaryNativeCode ];
    maintainers = [ ];
  };
}
