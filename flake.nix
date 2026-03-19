{
  description = "Zephyrus G16 NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Add Home Manager input
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; # Keeps HM in sync with your system pkgs
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    {
      nixosConfigurations.msolinsk = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          # Add the Home Manager NixOS module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.msolinsk = {
              imports = [
                ./home.nix
                inputs.spicetify-nix.homeManagerModules.default
              ];
            };

            # This allows Home Manager to see the 'inputs' variable
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
        ];
      };
    };
}
