{ config, lib, inputs, pkgs, ... }:
let
  cfg = config.sees;
in
{
  config = 
    let
      main_template = builtins.readFile ./main.conf.j2;
      mavlink_config = pkgs.sees-lib.jinja "main.conf" main_template
      {
          uart_device = "follows";
          uart_baud = "bar";
          udp_port_qgc = "";
          udp_port_sls = "";
          udp_port_unused = "";
      };
    in
    {
      systemd.services = {
        mavlink-router = {
          description = "MAVLink Router";
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "simple";
            ExecStart = "${pkgs.mavlink-router}/bin/mavlink-routerd -c ${mavlink_config}";
            Restart = "on-failure";
            RestartSec = 2;
          };
        };

        mavsdk-server = {
          description = "MAVSDK Server";
          wants = [ "mavlink-router.service" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "simple";
            ExecStart = "${pkgs.mavsdk-server}/bin/mavsdk-server --sysid {{ mavsdk_server_default_sysid }} --compid {{ mavsdk_server_default_compid }} {{ connection_url }}";
            Restart = "on-failure";
          };
        };
      };
    };
}
