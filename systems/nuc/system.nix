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
      hashedPassword = "$y$j9T$c9HsBtDvOugGTPwXwMFwY1$Ey/PmzgJaa3E/CloTfQZ5BoGAak3Xq7MdmtRVAsK7./";
    };
    security.sudo.wheelNeedsPassword = false;

    nix.settings.trusted-users = [ "rpickler" ];

    services.openssh.enable = true;
  };
in
{ 
  system = "x86_64-linux";
  modules = [
    {nixpkgs.overlays = [ inputs.sees-ai.overlay ];}
    inputs.sops-nix.nixosModules.sops
    inputs.disko.nixosModules.disko
    ./hardware.nix
    ./filesystems.nix
    ./SeesInterface2.nix
    config
  ];
  specialArgs = { inherit inputs; };
}
