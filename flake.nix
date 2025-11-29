{
  description = "Very basic terminal character generator for mothership";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = inputs: {

    packages = builtins.mapAttrs (system: pkgs: {
      mothershipper = pkgs.callPackage ./default.nix { };
      motherwebber = pkgs.callPackage ./web.nix { inherit (inputs.self.packages.${system}) mothershipper; };
      default = inputs.self.packages.${system}.mothershipper;
    }) inputs.nixpkgs.legacyPackages;

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
            chdir = inputs.self.packages.x86_64-linux.mothershipper + "/bin";
            module = "mothershipper:application";
          };
        };
      };
    };

    nixosConfigurations.test-vm = inputs.nixpkgs.lib.nixosSystem {
      modules = [ inputs.self.nixosModules.mothershipper ./test-vm.nix ];
    };

  };
}
