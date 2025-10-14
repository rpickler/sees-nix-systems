{
  description = "Sees.Ai Nixos Configurations";

  nixConfig = {
    extra-substituters = [
      "https://attic.richardpickler.com/sees-ai"
    ];
    extra-trusted-public-keys = [
      "sees-ai:rpfOAiYQBwEdvmMrgHzksYeNjosXcdzg2Jv4ieCOGw4="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nvmd/disko/gpt-attrs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sees-interface = {
      # have to use this format to get use .git-credentials
      url = "git+https://github.com/SEESAI/SeesInterface2?ref=RP-nix";
      #url = "/home/rpickler/devel/sees.ai/SeesInterface2.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sees-cloud-services = {
      url = "git+https://github.com/SEESAI/SeesCloudServices?ref=RP-nix";
      #url = "/home/rpickler/devel/sees.ai/SeesCloudServices.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-system-graphics = {
      url = "github:soupglasses/nix-system-graphics";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, system-manager, nix-system-graphics, ... }@inputs: 
  let
      seesSystem = args: (
        nixpkgs.lib.nixosSystem (
          import ./systems/${args.type}/system.nix { 
            inherit inputs; 
            inherit (args) name;
          }
        ));
  in
  {
    nixosConfigurations = {
      yealm-7 = seesSystem {
        name = "yealm-7";
        type = "nuc";
      };
    };

    systemConfigs = 

    rec {
      default = ubuntu.amd;

      ubuntu = {
        nvidia = system-manager.lib.makeSystemConfig {
          modules = [
            nix-system-graphics.systemModules.default

            ({
              config =
              let
                pkgs = import nixpkgs {
                  system = "x86_64-linux";
                  config.allowUnfree = true;
                };

                      #nvidia-driver = ;
              in {
                nixpkgs.hostPlatform = "x86_64-linux";
                system-manager.allowAnyDistro = true;
                nix.settings.experimental-features = [ "nix-command" "flakes" ];
                system-graphics.enable = true;
                system-graphics.package = pkgs.linuxPackages.nvidia_x11.override { libsOnly = true; kernel = null; };
              };
            })
          ];
        };
        amd = system-manager.lib.makeSystemConfig {
          modules = [
            nix-system-graphics.systemModules.default
            ({
              config = {
                nixpkgs.hostPlatform = "x86_64-linux";
                system-manager.allowAnyDistro = true;
                system-graphics.enable = true;
              };
            })
          ];
        };
      };
    };
  };
}
