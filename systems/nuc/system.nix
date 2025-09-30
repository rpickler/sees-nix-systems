{ inputs, name, ... }:
let
  config = {
    networking.hostName = name;
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

  # Build everything highly optimized.  Appears problematic right now when
  # remote building.
  #
  # https://nixos.wiki/wiki/Build_flags
  # https://github.com/NixOS/nixpkgs/blob/master/lib/systems/architectures.nix
  pkgsOverride = (inputs: {
    nixpkgs = {
      hostPlatform = {
  #      gcc.arch = "alderlake";
  #      gcc.tune = "alderlake";
        system = "x86_64-linux";
      };
    };
  });
in
{ 
  modules = [
    pkgsOverride
      #{nixpkgs.overlays = [ 
      #  inputs.sees-interface.overlays.default 
      #];}
    inputs.sops-nix.nixosModules.sops
    inputs.disko.nixosModules.disko
    {
      # I didn't name tmpfiles.
      # https://discourse.nixos.org/t/is-it-possible-to-declare-a-directory-creation-in-the-nixos-configuration/27846
      systemd.tmpfiles.rules = [
        "d /opt/sees/bin"
        "d /opt/sees/cache"
      ];
    }
    ../../modules/sees-global-config.nix
    ../../modules/sees-routing-demo.nix
    #../modules/sops.nix
    #../modules/core-dump-tracker.nix
    #../modules/disable-screensaver.nix
    #../modules/sees-client-certificate.nix
    #../modules/wireguard.nix
    # TODO: ../modules/mavsdk-server.nix
    #../../modules/sees-local-service.nix
    # TODO: ../modules/supervisor.nix
    # TODO: ../modules/sees-wizard.nix
    # TODO: ../modules/vncserver.nix
    # TODO: ../modules/ouster.nix
    # TODO: ../modules/doodlelabs.nix
    # TODO: ../modules/qgc.nix
    # TODO: ../modules/sees-fastapi-server.nix
    # TODO: ../modules/sees-backup-fpv.nix
    # TODO: ../modules/mavlink-router.nix
    ./hardware.nix
    ./filesystems.nix
    #./SeesInterface2.nix
    config
  ];
  specialArgs = { inherit inputs; };

  #core-dump-tracker.dir = "/opt/sees/CoreDumps";
}
