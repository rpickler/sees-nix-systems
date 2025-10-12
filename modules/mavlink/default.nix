{ config, lib, inputs, pkgs, ... }:
let
  cfg = config.sees;
in
{
  options.sees = with lib; with types; {
    mavlink = {
      uart_device = mkOption {
        type = str;
        default = "/dev/ttyPX4";
      };

      uart_baud = mkOption {
        type = int;
        default = 57600;
      };

      udp_port_qgc = mkOption {
        type = int;
        default = 14550;
      };

      udp_port_sls = mkOption {
        type = int;
        default = 15550;
      };

      udp_port_unused = mkOption {
        type = int;
        default = 17550;
      };
    };
    
    mavsdk-server = {
      connection_url = mkOption {
        type = str;
        default = "udp://:$(builtins.toString mavlink.udp_port_sls)";
      };

      default_sysid = mkOption {
        type = int;
        default = 245;
      };

      default_compid = mkOption {
        type = int;
        default = 190;
      };
    };
  };

  config = 
    let
      main_template = builtins.readFile ./main.conf.j2;
      mavlink_config = pkgs.sees-lib.jinja "main.conf" main_template
      {
          uart_device = cfg.mavlink.uart_device;
          uart_baud = builtins.toString cfg.mavlink.uart_baud;
          udp_port_qgc = builtins.toString cfg.mavlink.udp_port_qgc;
          udp_port_sls = builtins.toString cfg.mavlink.udp_port_sls;
          udp_port_unused = builtins.toString cfg.mavlink.udp_port_unused;
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
            ExecStart = "${pkgs.mavsdk}/bin/mavsdk-server --sysid $(builtins.toString cfg.mavsdk-server.default_sysid) --compid $(builtins.toString cfg.mavsdk-server.default_compid) ${cfg.mavsdk-server.connection_url}";
            Restart = "on-failure";
          };
        };
      };
    };
}
