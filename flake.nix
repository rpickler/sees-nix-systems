{
  description = "Sees.Ai Nixos Configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    sops-nix.url = "github:mic92/sops-nix";
    disko.url = "github:nvmd/disko/gpt-attrs";
    sees-ai.url = "/home/rpickler/devel/sees.ai/sees-nix-packages";
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
