{ config, lib, sops, ... }:
let
  cfg = config.sees;
in
{
  options.sees.sls = with lib; with types; {
    service_user = mkOption {
      type = str;
      default = "sees";
    };
  };

  config = {
    systemd.tmpfiles.rules = [
      "d /opt/sees/cache/SLS"
    ]; 

    systemd.services.sees-local-service = {
      description = "SeesAI Local Service {{ sls_version }}";
      wantedBy = [ "multi-user.target" ];
      requires = [ "network-online.target" ];
      wants = [ "mavsdk-server.service" ];
      after = ["multi-user.target" "mavsdk-server.service"];

      serviceConfig = {
        Type = "simple";
        ExecStart="{{ sls_app_dir }}/bin/sees-local-service {{ sls_conf_dir }}/main.yml";
        User = "${cfg.sls.service_user}";
        Environment = "DISPLAY=:0";
        Restart = "on-failure";
      };
    };
  };
}
