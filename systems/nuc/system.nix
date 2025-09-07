{ inputs, ... }:
let
  config = {
    networking.hostName = "nuc";
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    boot.loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
      };
    };

    users.users.rpickler = {
      isNormalUser = true;
      description = "Richard Pickler";
      extraGroups = [ "networkmanager" "wheel" "video" ];
    };
    security.sudo.wheelNeedsPassword = false;
  };
in
{ 
  system = "x86_64-linux";
  modules = [
    {nixpkgs.overlays = [ inputs.sees-ai.overlay ];}
    inputs.sops-nix.nixosModules.sops
    inputs.disko.nixosModules.disko
    ./filesystems.nix
    ./SeesInterface2.nix
    config
  ];
  specialArgs = { inherit inputs; };
}
