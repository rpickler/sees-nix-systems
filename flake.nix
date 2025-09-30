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
      url = "/home/rpickler/devel/sees.ai/SeesCloudServices.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: 
  let
      seesSystem = args: (
        nixpkgs.lib.nixosSystem (
          import ./systems/${args.type}/system.nix { 
            inherit inputs; 
            inherit (args) name;
            inherit (args) interfaces;
          }
        ));
  in
  {
    nixosConfigurations = {
      drone = seesSystem {
        name = "drone";
        type = "nuc";
          #interfaces = [ "p2p" ];
          interfaces = [ "p2p" "o2" "ee" "voda" ];
      };

      van = seesSystem {
        name = "van";
        type = "nuc";
          #interfaces = [ "p2p" ];
          interfaces = [ "p2p" "o2" "ee" "voda" ];
      };

      cloud = seesSystem {
        name = "cloud";
        type = "nuc";
        interfaces = [ "uplink" ];
      };

      gcs = seesSystem {
        name = "gcs";
        type = "nuc";
        interfaces = [ "uplink" ];
      };
    };
  };
}
