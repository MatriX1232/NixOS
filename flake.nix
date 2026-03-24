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

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      spicetify-nix,
      cachyos-kernel,
      lanzaboote,
      ...
    }@inputs:
    {
      nixosConfigurations.msolinsk = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          lanzaboote.nixosModules.lanzaboote

          {
            nixpkgs.overlays = [ inputs.cachyos-kernel.overlays.pinned ];
          }

          # Add the Home Manager NixOS module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.msolinsk = {
              imports = [
                ./home.nix
                spicetify-nix.homeManagerModules.default
              ];
            };

            # This allows Home Manager to see the 'inputs' variable
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
        ];
      };
    };
}
