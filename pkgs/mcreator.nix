{ lib, stdenv, fetchurl, autoPatchelfHook, copyDesktopItems, makeWrapper
, makeDesktopItem, writeShellScript, alsa-lib, at-spi2-atk, at-spi2-core, atk
, cairo, coreutils, cups, dbus, expat, fontconfig, freetype, glib, gnugrep, gtk3
, jdk17, jdk21, libGL, libdrm, libgbm, libxkbcommon, nspr, nss, pango
, systemdLibs, wayland, xdg-utils, xorg, zlib }:

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

  # Forge and NeoForge ask Gradle for a specific Java toolchain -- 21 for the
  # current Minecraft generators, 17 for the older ones -- and it is never the
  # JDK MCreator itself runs on. MCreator launches Gradle with
  # -Porg.gradle.java.installations.auto-detect=false, so Gradle will not go
  # looking for one; left alone it downloads a JDK from foojay, which on NixOS
  # both fails to unpack and would not be runnable if it did. Hand it ours, and
  # turn the download off so a toolchain we don't ship fails loudly.
  javaToolchains = [ jdk17 jdk21 ];

  toolchainPaths = lib.concatMapStringsSep "," (jdk: jdk.home) javaToolchains;

  # MCreator strips GRADLE_OPTS, GRADLE_USER_HOME, JAVA_HOME and friends out of
  # the environment it hands Gradle (net.mcreator.gradle.GradleUtils), so the
  # only channel left is gradle.properties in its Gradle home. MCreator never
  # writes that file itself, so seeding it is safe -- but regenerate it every
  # launch, since the store paths in it go stale on garbage collection, and
  # back off entirely once it stops looking like ours.
  seedGradleProperties = writeShellScript "mcreator-seed-gradle-properties" ''
    export PATH=${lib.makeBinPath [ coreutils gnugrep ]}:"$PATH"

    marker="# Managed by the mcreator Nix package."
    gradleHome="''${MCREATOR_HOME:-$HOME/.mcreator}/gradle"
    props="$gradleHome/gradle.properties"

    if [ -e "$props" ] && ! head -n 1 "$props" | grep -qxF "$marker"; then
      echo "mcreator: $props is not ours, leaving it alone." >&2
      echo "mcreator: if Gradle cannot find a Java toolchain, add:" >&2
      echo "mcreator:   org.gradle.java.installations.paths=${toolchainPaths}" >&2
      exit 0
    fi

    mkdir -p "$gradleHome"
    {
      echo "$marker"
      echo "# Rewritten on launch. Change the first line to take it over."
      echo "org.gradle.java.installations.paths=${toolchainPaths}"
      echo "org.gradle.java.installations.auto-download=false"
    } > "$props"
  '';

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
    # read-only-safe: user data goes to $MCREATOR_HOME, default ~/.mcreator.
    makeWrapper $out/share/mcreator/jdk/bin/java $out/bin/mcreator \
      --run ${seedGradleProperties} \
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

      User data -- workspaces, preferences, Gradle caches -- lives under
      $MCREATOR_HOME, which defaults to ~/.mcreator. Gradle's own toolchain
      auto-provisioning does not work on NixOS, so the JDKs Forge and NeoForge
      build against come from nixpkgs instead, written into
      $MCREATOR_HOME/gradle/gradle.properties on launch. Building a mod still
      fetches Minecraft and mod-loader artifacts on first use, so the machine
      needs network access the first time a workspace is opened.
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
