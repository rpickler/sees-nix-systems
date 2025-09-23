{ config, lib, sops, ... }:
let
  cfg = config.sees;
in
{
  config = {
    systemd.network = {
      enable = true;
      networks."50-wg0" = {
        matchConfig.Name = "wg0";
        address = [
          "192.168.1.100/32"
        ];
      };
      netdevs."50-wg0" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg0";
        };
        wireguardConfig = {
          ListenPort = 51820;
          PrivateKeyFile = "${config.sops.${cfg.drone_name}.wireguard.private_key.path}";
          RouteTable = "main";
          FirewallMark = 42;
        };
        wireguardPeers = [
          {
            PublicKeyFile = "${config.sops.central.wireguard.public_key.path}";
            AllowedIPs = [
              "192.168.1.1/32"
            ];
            Endpoint = "91.1.123.91";
          }
          {
            PublicKeyFile = "${config.sops.lavant.wireguard.public_key.path}";
            AllowedIPs = [
              "192.168.1.1/32"
            ];
            Endpoint = "91.1.123.92";
          }
        ];
      };
    };
  };
}
