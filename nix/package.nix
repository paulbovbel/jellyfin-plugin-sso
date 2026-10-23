{
  lib,
  buildDotnetModule,
  dotnetCorePackages,
}:
let
  pluginFiles = [
    "SSO-Auth.dll"
    "Duende.IdentityModel.dll"
    "Duende.IdentityModel.OidcClient.dll"
  ];
in
buildDotnetModule {
  pname = "jellyfin-plugin-sso";
  version = "5.1.1";

  src = lib.cleanSource ../.;
  projectFile = "SSO-Auth/SSO-Auth.csproj";
  nugetDeps = ./deps.json;
  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.aspnetcore_10_0;
  executables = [ ];
  dotnetBuildFlags = [ "-p:CopyLocalLockFileAssemblies=true" ];
  passthru = { inherit pluginFiles; };

  # Jellyfin loads the plugin and supplies its own runtime and server assemblies.
  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    for file in ${lib.escapeShellArgs pluginFiles}; do
      cp SSO-Auth/bin/Release/net10.0/*/"$file" "$out/"
    done
    runHook postInstall
  '';

  meta = {
    description = "Single sign-on authentication plugin for Jellyfin";
    homepage = "https://github.com/paulbovbel/jellyfin-plugin-sso";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
}
