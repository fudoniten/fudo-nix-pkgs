{ lib, stdenv, fetchurl, autoPatchelfHook, copyDesktopItems, makeWrapper
, makeDesktopItem, alsa-lib, glib, gtk3, libGL, libpulseaudio, libxkbcommon
, systemdLibs, vulkan-loader, xdg-utils, zlib, libx11, libxcursor, libxext
, libxi, libxinerama, libxrandr, libxrender, libxscrnsaver, libxxf86vm, libxcb
}:

let
  # ChroMapper builds are numbered by their Jenkins build, and the release
  # version is <series>.<build>: GitHub tag 0.13.892 is build 892.
  version = "0.13.892";
  build = lib.last (lib.splitVersion version);

  # Unity's player links almost nothing directly. Graphics, windowing, input
  # and audio are all dlopened at runtime, which autoPatchelf can't see, hence
  # the LD_LIBRARY_PATH on the wrapper below. gtk3 is for the
  # StandaloneFileBrowser native plugin behind the open/save dialogs.
  runtimeLibs = [
    alsa-lib
    glib
    gtk3
    libGL
    libpulseaudio
    libxkbcommon
    stdenv.cc.cc.lib
    systemdLibs
    vulkan-loader
    zlib
    libx11
    libxcursor
    libxext
    libxi
    libxinerama
    libxrandr
    libxrender
    libxscrnsaver
    libxxf86vm
    libxcb
  ];

in stdenv.mkDerivation {
  pname = "chromapper";
  inherit version;

  # Upstream only publishes builds through the ChroMapper Launcher's download
  # server; the GitHub releases carry source archives only. This is the same
  # tarball the launcher installs on Linux. The URL is undocumented, so if it
  # moves, check the AUR's chromapper-bin, which tracks it.
  src = fetchurl {
    url = "https://cm.topc.at/nix/${build}/Linux.tar.gz";
    hash = "sha256-9MTyGZqLT+1MXNKWEFIytfjvATq1Gg9AJCFhM1Llrlw=";
  };

  icon = fetchurl {
    url = "https://cm.topc.at/cm.svg";
    hash = "sha256-Uzva6MfpWpSklBoB3l8O6UaErCEZ1yl+T1q+lQ7GToA=";
  };

  sourceRoot = "chromapper";

  nativeBuildInputs = [ autoPatchelfHook copyDesktopItems makeWrapper ];

  buildInputs = runtimeLibs;

  dontConfigure = true;
  dontBuild = true;
  # Unity players break when their bundled Mono and native plugins are
  # stripped.
  dontStrip = true;

  # ChroMapper loads plugins from ./Plugins relative to its working directory
  # and creates it on startup, so it can't run from the store. Settings, logs
  # and keybinds go to Unity's persistentDataPath
  # (~/.config/unity3d/BinaryElement/ChroMapper), which is fine as is; only the
  # working directory has to move somewhere writable. The player finds its
  # ChroMapper_Data next to the real executable, not the working directory, so
  # exec'ing the store binary from elsewhere is safe.
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/chromapper
    cp -r . $out/share/chromapper/
    chmod +x $out/share/chromapper/ChroMapper

    makeWrapper $out/share/chromapper/ChroMapper $out/bin/chromapper \
      --run 'cmHome="''${CHROMAPPER_HOME:-''${XDG_DATA_HOME:-$HOME/.local/share}/ChroMapper}"' \
      --run 'mkdir -p "$cmHome/Plugins" && cd "$cmHome"' \
      --prefix PATH : ${lib.makeBinPath [ xdg-utils ]} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}

    install -Dm444 $icon \
      $out/share/icons/hicolor/scalable/apps/chromapper.svg

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "chromapper";
      desktopName = "ChroMapper";
      comment = "Map editor for Beat Saber";
      exec = "chromapper";
      icon = "chromapper";
      categories = [ "Game" "Utility" ];
      keywords = [ "Beat Saber" "Map" "Level" "Editor" ];
    })
  ];

  meta = {
    description = "Unity-based map editor for Beat Saber";
    longDescription = ''
      ChroMapper is a map (level) editor for Beat Saber, with support for
      Chroma, Noodle Extensions and Mapping Extensions. This is upstream's
      prebuilt Linux build, the same one the ChroMapper Launcher installs,
      patched to run outside an FHS tree.

      The working directory is $CHROMAPPER_HOME, which defaults to
      $XDG_DATA_HOME/ChroMapper; ChroMapper plugins (.dll) go in its Plugins
      subdirectory. Settings and logs live in
      ~/.config/unity3d/BinaryElement/ChroMapper. The in-app updater is
      inert, since it relies on the launcher; bump the version here instead.
      Uploading to a Quest over adb is not supported, because ChroMapper
      unpacks adb next to its own install, which is read-only.
    '';
    homepage = "https://github.com/Caeden117/ChroMapper";
    downloadPage = "https://cm.topc.at/dl";
    license = lib.licenses.gpl2Only;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "chromapper";
    maintainers = [ ];
  };
}
