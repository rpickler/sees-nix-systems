{ config, lib, inputs, pkgs, ... }:
let
  cfg = config.sees;
in
{
  config = 
    let
      main_template = ''
[UartEndpoint PX4]
Device = {{ uart_device }}
Baud = {{ uart_baud }}

[UdpEndpoint QGC]
Mode = Normal
Address = 127.0.0.1
Port = {{ udp_port_qgc }}

[UdpEndpoint SLS]
Mode = Normal
Address = 127.0.0.1
Port = {{ udp_port_sls }}

[UdpEndpoint Spare]
Mode = Normal
Address = 127.0.0.1
Port = {{ udp_port_unused }}
      '';
      jinja = (import ../lib/jinja.nix { inherit pkgs; });
      mavlink_config = jinja "main.conf" main_template
      {
          uart_device = "";
          uart_baud = "";
          udp_port_qgc = "";
          udp_port_sls = "";
          udp_port_unused = "";
      };
    in
    {
      systemd.services.mavlink-router = {
        description = "MAVLink Router";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.mavlink-router}/bin/mavlink-routerd -c ${mavlink_config}";
          Restart = "on-failure";
          RestartSec = 2;
        };
      };
    };
}
