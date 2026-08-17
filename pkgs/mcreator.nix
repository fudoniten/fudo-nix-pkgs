{ lib, stdenv, fetchurl, autoPatchelfHook, copyDesktopItems, makeWrapper
, makeDesktopItem, alsa-lib, at-spi2-atk, at-spi2-core, atk, cairo, cups, dbus
, expat, fontconfig, freetype, glib, gtk3, libGL, libdrm, libgbm, libxkbcommon
, nspr, nss, pango, systemdLibs, wayland, xdg-utils, xorg, zlib }:

let
  version = "2026.2.33518";

  # Upstream names the release asset and the archive's top-level directory for
  # the major.minor series, not the full build number: the tag is
  # 2026.2.33518, but the tarball is "MCreator.2026.2.Linux.64bit.tar.gz" and
  # unpacks to MCreator20262/.
  series = lib.versions.majorMinor version;
  seriesCompact = builtins.replaceStrings [ "." ] [ "" ] series;

  # Everything the bundled JetBrains Runtime and its JCEF (Chromium) build pull
  # in via DT_NEEDED, plus fontconfig and libGL, which the JDK and JOGL only
  # ever dlopen -- autoPatchelf can't see those, hence the LD_LIBRARY_PATH on
  # the wrapper below.
  runtimeLibs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    glib
    gtk3
    libGL
    libdrm
    libgbm
    libxkbcommon
    nspr
    nss
    pango
    stdenv.cc.cc.lib
    systemdLibs
    wayland
    zlib
  ] ++ (with xorg; [
    libX11
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libXrandr
    libXrender
    libXtst
    libXxf86vm
    libxcb
  ]);

in stdenv.mkDerivation {
  pname = "mcreator";
  inherit version;

  src = fetchurl {
    url =
      "https://github.com/MCreator/MCreator/releases/download/${version}/MCreator.${series}.Linux.64bit.tar.gz";
    hash = "sha256-ay4GKvC62gqI6yZaOvSo2nwxfQLoQ/FRAbNJE+u3wII=";
  };

  sourceRoot = "MCreator${seriesCompact}";

  nativeBuildInputs = [ autoPatchelfHook copyDesktopItems makeWrapper ];

  buildInputs = runtimeLibs;

  dontConfigure = true;
  dontBuild = true;

  # The tarball is a self-contained bundle: MCreator's jars in lib/, its
  # built-in plugins, and a full JetBrains Runtime 25 (with JCEF) in jdk/.
  # Keep it intact and let autoPatchelf fix up the prebuilt ELFs in place.
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/mcreator
    cp -r jdk lib plugins license LICENSE.txt icon.png $out/share/mcreator/

    # Upstream's mcreator.sh writes a .desktop file next to itself on every
    # launch, which can't work from the store, so launch the entry point
    # directly and ship a real desktop item instead. MCreator takes its
    # installation path from user.dir and resolves lib/ and plugins/ relative
    # to it, so the working directory has to be the install root -- that's
    # read-only-safe, since user data goes to $MCREATOR_HOME (default $HOME).
    makeWrapper $out/share/mcreator/jdk/bin/java $out/bin/mcreator \
      --chdir $out/share/mcreator \
      --set CLASSPATH './lib/mcreator.jar:./lib/*' \
      --prefix PATH : ${lib.makeBinPath [ xdg-utils ]} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs} \
      --add-flags "--add-opens=java.base/java.lang=ALL-UNNAMED" \
      --add-flags "--enable-native-access=ALL-UNNAMED,jcef" \
      --add-flags net.mcreator.Launcher

    install -Dm444 icon.png \
      $out/share/icons/hicolor/64x64/apps/mcreator.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "mcreator";
      desktopName = "MCreator";
      comment = "Minecraft mod maker and data pack editor";
      exec = "mcreator %f";
      icon = "mcreator";
      categories = [ "Development" "IDE" ];
      keywords = [ "Minecraft" "Mod" "Forge" "NeoForge" ];
    })
  ];

  meta = {
    description = "Minecraft mod maker, data pack and add-on editor";
    longDescription = ''
      MCreator is an IDE for building Minecraft mods, data packs, resource
      packs and Bedrock add-ons, either visually with Blockly or in Java. This
      is upstream's prebuilt Linux bundle: the jars plus a bundled JetBrains
      Runtime 25 with JCEF, patched to run outside an FHS tree.

      User data (workspaces, preferences, downloaded Gradle and mod toolchains)
      lives under $MCREATOR_HOME, which defaults to the user's home directory.
      Building a mod downloads its toolchain on first use, so the machine needs
      network access the first time a workspace is opened.
    '';
    homepage = "https://mcreator.net/";
    downloadPage = "https://github.com/MCreator/MCreator/releases";
    license = lib.licenses.gpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "mcreator";
    maintainers = [ ];
  };
}
