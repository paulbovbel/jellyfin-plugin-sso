# Nix package

Build the plugin with `nix build`. The output contains `SSO-Auth.dll` and its
two Duende dependencies at the top level, ready for a Jellyfin plugin directory.
Packages are exposed for `x86_64-linux` and `aarch64-linux` as both `default`
and `jellyfin-plugin-sso`.

This branch targets Jellyfin 12 and .NET 10. The running Jellyfin server must
be compatible; packaging does not make this plugin compatible with Jellyfin 10.

## Use from nix-config

Add an input to `~/nix-config/flake.nix` and pass it to your NixOS modules using
your existing input plumbing:

```nix
inputs.jellyfin-sso = {
  url = "github:paulbovbel/jellyfin-plugin-sso";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

For the existing LinuxServer Jellyfin container, add a read-only volume in
`modules/media-server/library/jellyfin.nix` (with `inputs` and `pkgs` available
as module arguments):

```nix
podmanServer.containers.jellyfin.quadlet.containerConfig.volumes = [
  "${inputs.jellyfin-sso.packages.${pkgs.stdenv.hostPlatform.system}.default}:/config/data/plugins/SSO-Auth_5.1.1:ro"
];
```

Remove any other installed copy of the SSO plugin before enabling this mount.
Keep plugin configuration in the writable Jellyfin config dataset, not in the
Nix store. Update the input lock to deploy a new plugin revision.

Alternatively, reuse the package definition directly with
`pkgs.callPackage "${inputs.jellyfin-sso}/nix/package.nix" { }`.
The consuming nixpkgs must provide the .NET 10 SDK and ASP.NET runtime.

## Updating dependencies

After changing NuGet references, regenerate the pinned dependency hashes:

```sh
nix build .#jellyfin-plugin-sso.fetch-deps -o /tmp/sso-fetch-deps
/tmp/sso-fetch-deps "$PWD/nix/deps.json"
nix build
```

Commit `nix/deps.json` together with the project changes. Dependency fetching
requires network access; the normal package build uses the pinned NuGet files.
