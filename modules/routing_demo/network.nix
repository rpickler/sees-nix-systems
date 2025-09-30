{ config, lib, inputs, pkgs, sops, ... }:
let
  cfg = config.demo.network;
in
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
  ];

  options.demo.network = with lib; with types; {

    interfaces = mkOption {
      type = listOf str;
      default = [];
    };

    hostname = mkOption {
      type = str;
      default = "drone";
    };
  };


  config = 
    let
      mac_addresses_left = builtins.map
        (ifname: builtins.substring 0 4 (builtins.hashString "md5" "${cfg.hostname}-${ifname}"))
        cfg.interfaces;

      mac_addresses_right = builtins.map
        (ifname: builtins.substring 4 8 (builtins.hashString "md5" "${cfg.hostname}-${ifname}"))
        cfg.interfaces;

      pairs = (lib.zipListsWith 
        (l: r: 
          (lib.zipListsWith 
            (x: y: x+y) 
            (lib.stringToCharacters l)
            (lib.stringToCharacters r)
          ))
        mac_addresses_left
        mac_addresses_right
      );

      mac_addresses =  builtins.map
        (v: "52:54:00:" + builtins.concatStringsSep ":" (lib.take 3 v))
        pairs;

      bridges = builtins.map
        (ifname: if ifname == "p2p" then "mock-p2p" else "mock-internet")
        cfg.interfaces;

      netdev_options = lib.imap0
        (index: interface: 
          let
            index_str = builtins.toString index;
          in
          "-netdev tap,id=nd${index_str},ifname=tap-${cfg.hostname}-${interface.fst},script=no,downscript=no,br=${interface.snd}")
        (lib.zipLists cfg.interfaces bridges);

      device_options = lib.imap0
        (index: mac: 
          let
            index_str = builtins.toString index;
          in
          "-device virtio-net-pci,netdev=nd${index_str},mac=${mac}")
        mac_addresses;

      ip_addrs = builtins.map
        (x: builtins.concatStringsSep "." 
          (builtins.map (y: builtins.toString (pkgs.lib.fromHexString y)) x)
        )
        pairs;

      subnet = "10.0." + builtins.toString (pkgs.lib.fromHexString (builtins.substring 0 2 (builtins.hashString "md5" cfg.hostname)));

      #start = pkgs.lib.fromHexString (builtins.substring 0 2 (builtins.hashString "md5" cfg.hostname));

      networks = builtins.listToAttrs (
          lib.imap1
            (index: interface: 
              let
                index_str = builtins.toString index;
              in
              {
              name = "30-${interface.fst}";
              value = {
                enable = true;
                matchConfig.MACAddress = interface.snd;
                linkConfig = {
                  # or "routable" with IP addresses configured
                  ActivationPolicy = "always-up";
                  RequiredForOnline = "no";
                };
                networkConfig = {
                  Address = [ (builtins.trace "${interface.fst} ${interface.snd} ${subnet}.${index_str}/16" "${subnet}.${index_str}/16") ];
                  # Bridge = "br0";
                };
              };
            })
            (lib.zipLists cfg.interfaces mac_addresses)
      );

      netdevs = builtins.listToAttrs (
        lib.map
          (interface: {
            name = "20-${interface}";
            value = {
              enable = true;
              netdevConfig = {
                Kind = "link";
                Name = interface;
              };
            };
          })
          cfg.interfaces
      );
          
    in
    {
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
        #netdevs = netdevs;
      networks = networks;
    };

    virtualisation = {
      qemu = {
        networkingOptions = netdev_options ++ device_options;
      };
    };
  };
}
