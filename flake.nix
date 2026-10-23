{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        rec {
          jellyfin-plugin-sso = pkgs.callPackage ./nix/package.nix { };
          default = jellyfin-plugin-sso;
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs = [
              pkgs.prettier
              pkgs.dotnetCorePackages.sdk_10_0
            ];
          };
        }
      );

      devShell = forAllSystems (system: self.devShells.${system}.default);
    };
}
