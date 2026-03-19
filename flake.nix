{
  description = "Zephyrus G16 NixOS Flake";

  inputs = {
    # We use the unstable branch for your rolling release vision
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Optional: Home Manager (if you want to manage your Zed/GNOME settings via Nix later)
    # home-manager.url = "github:nix-community/home-manager";
    # home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    {
      # Replace 'msolinsk' with your actual networking.hostName if it's different
      nixosConfigurations.msolinsk = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
        ];
      };
    };
}
