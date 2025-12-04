{
  description = "NixOS-WSL configuration with flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/0.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-wsl, determinate, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            nixos-wsl.nixosModules.wsl
            determinate.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.david = import ./home.nix;
            }
            ./configuration.nix
          ];
        };
      };
      homeConfigurations.david = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
        extraSpecialArgs = { inherit self; };
      };

      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          alejandra
          nixd
          nixpkgs-fmt
          nil
          statix
        ];
        shellHook = ''
          echo "NixOS-WSL development environment"
          echo "Available tools: alejandra, nixd, nixpkgs-fmt, nil, statix"
        '';
      };
    };
}
