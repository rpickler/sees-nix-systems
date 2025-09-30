{ config, lib, inputs, sops, ... }:
let
  cfg = config.demo;
in
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
  ];

  options.demo = with lib; with types; {
    # I guess that every vm needs a unique MAC address.
    tap_macaddress = mkOption {
      type = str;
      default = "52:54:98:76:54:03";
    };

    # Every vm needs a unique IP address.
    tap_network_addr = mkOption {
      type = str;
      default = "192.168.100.3/24";
    };

    # Every tap device on the host can only be connected to one vm.
    tap_if_name = mkOption {
      type = str;
      default = "tap-van-o2";
    };

    # I dont know if this is needed.
    tap_bridge_name = mkOption {
      type = str;
      default = "mock-internet";
    };
  };


  config = {
    # Stolen from:
    # https://discourse.nixos.org/t/setup-networking-between-multiple-vms/44910

    # Other useful references:
    # https://brianlinkletter.com/2019/02/build-a-network-emulator-using-libvirt/
    # https://netbeez.net/blog/how-to-use-the-linux-traffic-control/
    # https://www.spad.uk/posts/really-simple-network-bridging-with-qemu/

    networking.firewall.enable = false;
    networking.networkmanager.enable = false;
    networking.useDHCP = lib.mkDefault false;

    systemd.network = {
      enable = true;
      networks."30-ethernet-dummy" = {
        enable = true;
        matchConfig.MACAddress = cfg.tap_macaddress;
        linkConfig = {
          # or "routable" with IP addresses configured
          ActivationPolicy = "always-up";
          RequiredForOnline = "yes";
        };
        networkConfig = {
          Address = [ cfg.tap_network_addr ];
          # Bridge = "br0";
        };
      };
    };

    virtualisation = {
      qemu = {
        networkingOptions = [  "-netdev tap,id=nd0,ifname=${cfg.tap_if_name},script=no,downscript=no,br=${cfg.tap_bridge_name}"  "-device virtio-net-pci,netdev=nd0,mac=${cfg.tap_macaddress}" ];
      };
    };
  };
}
