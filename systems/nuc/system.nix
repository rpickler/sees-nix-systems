{ inputs, ... }:
let
  config = {
    networking.hostName = "nuc";
    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      system-features = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
        "gccarch-alderlake"
      ];
    };

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

  pkgsOverride = (inputs: {
    nixpkgs = {
      hostPlatform = {
        gcc.arch = "alderlake";
        gcc.tune = "alderlake";
        system = "x86_64-linux";
      };
    };
  });
in
{ 
  modules = [
    # https://nixos.wiki/wiki/Build_flags
    # https://github.com/NixOS/nixpkgs/blob/master/lib/systems/architectures.nix
    pkgsOverride

    {nixpkgs.overlays = [ inputs.sees-interface.overlays.default ];}
    inputs.sops-nix.nixosModules.sops
    inputs.disko.nixosModules.disko
    ./hardware.nix
    ./filesystems.nix
    ./SeesInterface2.nix
    config
  ];
  specialArgs = { inherit inputs; };
}
