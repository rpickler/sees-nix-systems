{
  description = "Sees.Ai Nixos Configurations";

  nixConfig = {
    access-tokens = [
      "github.com=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"
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
      url = "/home/rpickler/devel/sees.ai/SeesInterface2.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: 
  {
    nixosConfigurations = (
      builtins.mapAttrs
        (name: _: nixpkgs.lib.nixosSystem (
          import ./systems/${name}/system.nix { inherit inputs; }
        ))
        (builtins.readDir ./systems)
      );
  };
}
