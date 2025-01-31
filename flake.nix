{
  description = "Very basic terminal character generator for mothership";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = inputs:
    let
      forSystems = function:
        inputs.nixpkgs.lib.genAttrs
        inputs.nixpkgs.lib.systems.flakeExposed
        (system: function inputs.nixpkgs.legacyPackages.${system})
      ;
    in
    {
      packages = forSystems (pkgs: let
        mothershipper = pkgs.callPackage ./default.nix {};
      in {
        inherit mothershipper;
        default = mothershipper;
      });
    };
}
