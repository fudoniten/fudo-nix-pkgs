# Builder for MCreator generator plugins.
#
# MCreator only ships NeoForge generators; everything else (Forge, Fabric,
# older Minecraft versions) is a plugin. A plugin is just a zip of a resource
# tree -- a plugin.json at the root plus a directory per generator -- and
# upstream's build.gradle produces it by pointing the `jar` task at
# src/main/resources and naming the output .zip. There is no code to compile,
# so all we do here is what Gradle's processResources would have done: expand
# the placeholders in plugin.json, then zip the tree back up.
#
# MCreator refuses to load a plugin whose supportedversions do not cover the
# running MCreator (net.mcreator.plugin.Plugin.isCompatible), so mcreatorVersion
# has to track the mcreator package: a plugin built for the wrong series is
# silently listed as incompatible rather than failing the build.

{ lib, stdenvNoCC, fetchFromGitHub, zip

, pname, version, owner, repo, rev, hash

# Placeholders upstream's processResources expands in plugin.json. They come
# from the plugin's gradle.properties -- keep them in sync with the pinned rev.
, mcVersion, mcreatorVersion, pluginVersion

, description, homepage, maintainers ? [ ] }:

let
  # MCreator encodes its version as one number: 2026.2 -> 2026002, and
  # 2026.2.33518 -> 202600233518. Plugins list the versions they support in
  # that form, so we have to reproduce upstream's arithmetic here.
  versionParts = lib.splitVersion mcreatorVersion;
  supportedVersion = builtins.elemAt versionParts 0
    + lib.fixedWidthString 3 "0" (builtins.elemAt versionParts 1)
    + lib.optionalString (builtins.length versionParts > 2)
    (builtins.elemAt versionParts 2);

  archiveName = "${pname}-${version}.zip";

  src = fetchFromGitHub { inherit owner repo rev hash; };

in stdenvNoCC.mkDerivation {
  inherit pname version src;

  # The plugin is the resource tree and nothing else.
  sourceRoot = "${src.name}/src/main/resources";

  nativeBuildInputs = [ zip ];

  dontConfigure = true;
  dontBuild = true;

  # "\''${name}" is how an indented Nix string spells a literal ${name}: these
  # are the Groovy template placeholders, not Nix interpolations.
  postPatch = ''
    substituteInPlace plugin.json \
      --replace-fail "\''${mcVersion}" "${mcVersion}" \
      --replace-fail "\''${mcreatorVersion}" "${mcreatorVersion}" \
      --replace-fail "\''${pluginVersion}" "${pluginVersion}" \
      --replace-fail "\''${supportedVersion}" "${supportedVersion}"
  '';

  # Zip it the way nixpkgs zips anything: fixed timestamps, no extra fields,
  # entries in a stable order, so the output is bit-identical between builds.
  installPhase = ''
    runHook preInstall

    mkdir -p $out
    find . -exec touch --date=@$SOURCE_DATE_EPOCH {} +
    find . -type f | sort | zip -q -X -@ $out/${archiveName}

    runHook postInstall
  '';

  passthru = { inherit mcVersion mcreatorVersion; };

  meta = {
    inherit description homepage maintainers;
    license = lib.licenses.gpl3Only;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    platforms = lib.platforms.all;
  };
}
