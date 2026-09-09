{ lib, stdenv, fetchurl, autoPatchelfHook, copyDesktopItems, makeWrapper
, makeDesktopItem, symlinkJoin, writeShellScript, alsa-lib, at-spi2-atk
, at-spi2-core, atk, cairo, coreutils, cups, dbus, expat, fontconfig, freetype
, glib, gnugrep, gtk3, jdk17, jdk21, libGL, libdrm, libgbm, libpulseaudio
, libxkbcommon, nspr, nss, pango, systemdLibs, wayland, xdg-utils, xorg, zlib

# JDKs offered to Gradle as Java toolchains, on top of the JetBrains Runtime 25
# MCreator bundles. One per Minecraft generation MCreator can target: 17 for
# Forge 1.20.1, 21 for NeoForge 1.21.1, 25 (the bundled JBR) for the 26.1
# generators. Add to this list to build for a generator we don't cover.
, javaToolchains ? [ jdk17 jdk21 ]

# MCreator generator plugins to make available in addition to the ones upstream
# bundles. See pkgs.nix for the ones we ship by default.
, extraPlugins ? [ ] }:

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
  # the wrapper below. libpulseaudio and libXinerama are neither: they are for
  # the LWJGL natives Minecraft itself unpacks and dlopens when a workspace is
  # run or debugged from inside MCreator.
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
    libpulseaudio
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
    libXinerama
    libXrandr
    libXrender
    libXtst
    libXxf86vm
    libxcb
  ]);

  # Every generator asks Gradle for a specific Java toolchain, and it is never
  # the JDK MCreator itself runs on: NeoForge 1.21.1 wants 21, Forge 1.20.1
  # wants 17, the 26.1 generators want 25. Gradle's own answer to a toolchain it
  # can't find is to download one from foojay, which on NixOS neither unpacks
  # nor runs, so we have to hand it JDKs from nixpkgs instead.
  #
  # The obvious channel -- org.gradle.java.installations.paths in the
  # gradle.properties of MCreator's Gradle home -- does not work, because
  # net.mcreator.gradle.GradleUtils launches every Gradle invocation with
  #
  #   -Porg.gradle.java.installations.auto-detect=false
  #   -Porg.gradle.java.installations.paths=<MCreator's own java.home>
  #
  # and a -P on the command line outranks gradle.properties, so the only
  # toolchain Gradle ends up seeing is the bundled JBR. installations.fromEnv is
  # the way in: MCreator never sets it, and it names *environment variables*
  # holding JDK paths, which survive the environment scrubbing GradleUtils does
  # (it drops JAVA_HOME, GRADLE_OPTS and friends, but nothing else). So the
  # toolchains travel as env vars set on the wrapper, and gradle.properties only
  # has to list their names.
  toolchainEnv = map (jdk: {
    name = "MCREATOR_JDK_${lib.versions.major jdk.version}";
    inherit (jdk) home;
  }) javaToolchains;

  toolchainEnvNames = lib.concatMapStringsSep "," (t: t.name) toolchainEnv;

  toolchainEnvFlags =
    lib.concatMapStringsSep " " (t: "--set ${t.name} ${t.home}") toolchainEnv;

  # MCreator never writes gradle.properties itself, so seeding it is safe -- but
  # rewrite it every launch so a change to the toolchain list takes effect, and
  # back off entirely once it stops looking like ours.
  seedGradleProperties = writeShellScript "mcreator-seed-gradle-properties" ''
    export PATH=${lib.makeBinPath [ coreutils gnugrep ]}:"$PATH"

    marker="# Managed by the mcreator Nix package."
    gradleHome="''${MCREATOR_HOME:-$HOME/.mcreator}/gradle"
    props="$gradleHome/gradle.properties"

    if [ -e "$props" ] && ! head -n 1 "$props" | grep -qxF "$marker"; then
      echo "mcreator: $props is not ours, leaving it alone." >&2
      echo "mcreator: if Gradle cannot find a Java toolchain, add:" >&2
      echo "mcreator:   org.gradle.java.installations.fromEnv=${toolchainEnvNames}" >&2
      exit 0
    fi

    mkdir -p "$gradleHome"
    {
      echo "$marker"
      echo "# Rewritten on launch. Change the first line to take it over."
      echo "org.gradle.java.installations.fromEnv=${toolchainEnvNames}"
      echo "org.gradle.java.installations.auto-download=false"
    } > "$props"
  '';

  # MCREATOR_PLUGINS_FOLDER is a third plugin directory MCreator reads after
  # ./plugins and $MCREATOR_HOME/plugins, which is exactly what we want: the
  # store-provided generators show up as ordinary user plugins, the read-only
  # bundle stays untouched, and dropping a plugin into $MCREATOR_HOME/plugins by
  # hand still works. It is not searched recursively, so the zips have to sit
  # directly in it.
  pluginsFolder = symlinkJoin {
    name = "mcreator-plugins";
    paths = extraPlugins;
  };

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
      ${toolchainEnvFlags} \
      ${
        lib.optionalString (extraPlugins != [ ])
        "--set MCREATOR_PLUGINS_FOLDER ${pluginsFolder}"
      } \
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
      keywords = [ "Minecraft" "Mod" "Forge" "NeoForge" "Fabric" ];
    })
  ];

  passthru = { inherit extraPlugins javaToolchains; };

  meta = {
    description = "Minecraft mod maker, data pack and add-on editor";
    longDescription = ''
      MCreator is an IDE for building Minecraft mods, data packs, resource
      packs and Bedrock add-ons, either visually with Blockly or in Java. This
      is upstream's prebuilt Linux bundle: the jars plus a bundled JetBrains
      Runtime 25 with JCEF, patched to run outside an FHS tree.

      User data -- workspaces, preferences, Gradle caches -- lives under
      $MCREATOR_HOME, which defaults to ~/.mcreator. Gradle's own toolchain
      auto-provisioning does not work on NixOS, so the JDKs the generators
      build against come from nixpkgs instead, passed in as environment
      variables that $MCREATOR_HOME/gradle/gradle.properties names on launch.

      Upstream bundles NeoForge, data pack, resource pack and Bedrock add-on
      generators only; Forge and Fabric come from third-party plugins, which
      this package builds from source and hands to MCreator through
      MCREATOR_PLUGINS_FOLDER. Further plugins can be dropped into
      $MCREATOR_HOME/plugins as usual, or added with
      `mcreator.override { extraPlugins = ...; }`.

      Building a mod still fetches Minecraft and mod-loader artifacts on first
      use, so the machine needs network access the first time a workspace is
      opened.
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
