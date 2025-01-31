{
  description = "Very basic terminal character generator for mothership";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }: let
    forSystems = function: nixpkgs.lib.genAttrs
      nixpkgs.lib.systems.flakeExposed
      (system: function nixpkgs.legacyPackages.${system});
  in {

    packages = forSystems (pkgs:
      {
        mothershipper = pkgs.callPackage ./default.nix { };
        motherwebber = pkgs.callPackage ./web.nix { inherit (self.packages.${pkgs.system}) mothershipper; };
        default = self.packages.${pkgs.system}.mothershipper;
      });

    nixosModules.mothershipper = {
      services.uwsgi = {
        enable = true;
        plugins = [ "python3" ];
        # capabilities = [ "CAP_NET_BIND_SERVICE" ];
        instance = {
          type = "emperor";
          vassals.mothershipper = {
            type = "normal";
            http = ":9280";
            # cap = "net_bind_service";
            chdir = self.packages.x86_64-linux.mothershipper + "/bin";
            module = "mothershipper:application";
          };
        };
      };
    };

    nixosConfigurations.test-vm = nixpkgs.lib.nixosSystem {
      modules = [ self.nixosModules.mothershipper ./test-vm.nix ];
    };

  };
}
