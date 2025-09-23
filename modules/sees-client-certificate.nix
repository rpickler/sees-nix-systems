{ config, lib, sops, ... }:
let
  cfg = config.sees;
in
{
  options.sees = with lib; with types; {
    pc_number = mkOption {
      type = str;
      example = "pc0001";
      default = "";
    };
    drone_name = mkOption {
      type = str;
      example = "yealm-3";
      default = "";
    };
  };

  config = lib.mkIf (cfg.drone_name != "") {
    sops.secrets.${cfg.drone_name}."sees-client-certificate" = {
      path = "/opt/sees/Config/Certificates/Client/client-${cfg.drone_name}-${cfg.pc_number}-crt.pem";
    };
    sops.secrets.${cfg.drone_name}."sees-client-sign" = {
      path = "/opt/sees/Config/Certificates/Client/client-${cfg.drone_name}-${cfg.pc_number}-csr.pem";
    };
    sops.secrets.${cfg.drone_name}."sees-client-key" = {
      path = "/opt/sees/Config/Certificates/Client/client-${cfg.drone_name}-${cfg.pc_number}-key.pem";
    };
  };
}
