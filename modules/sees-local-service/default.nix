{ config, lib, sops, inputs, pkgs, ... }:
let
  cfg = config.sees;
in
{
  options.sees.sls = with lib; with types; {
    service_user = mkOption {
      type = str;
      default = "sees";
    };

    config_dir = mkOption {
      type = str;
      default = "cache/SLS";
    };

    mode = mkOption {
      type = str;
      default = "sls";
    };

    das_power_command_scope = mkOption {
      type = str;
      default = "system";
    };
  };

  config = 
    let
      scs = inputs.sees-cloud-services.packages.${pkgs.system}.default;

      main_config = pkgs.sees-lib.jinja "main.yml" 
        (builtins.readFile ./sls_main.yml.j2) 
        {
          app_config = app_config;
        };

      app_config = pkgs.sees-lib.jinja "app_config.yml"
        (builtins.readFile ./sls_app_config.yml.j2)
        {
          sees_interface_config = sees_interface_config;
        };

      sees_interface_config = pkgs.sees-lib.jinja "sees_interface_config.yml"
        (builtins.readFile ./sls_sees_interface.yml.j2)
        {
        };
    in
    {
    environment.systemPackages = [
      scs
    ];

    systemd.tmpfiles.rules = [
      "d ${cfg.sees_dir}/${cfg.sls.config_dir}"
    ]; 



    systemd.services.sees-local-service = {
      description = "SeesAI Local Service {{ sls_version }}";
      wantedBy = [ "multi-user.target" ];
      requires = [ "network-online.target" ];
      wants = [ "mavsdk-server.service" ];
      after = ["multi-user.target" "mavsdk-server.service"];

      serviceConfig = {
        Type = "simple";
        ExecStart="${scs}/bin/sees-local-service ${main_config}";
        User = "${cfg.sls.service_user}";
        Environment = "DISPLAY=:0";
        Restart = "on-failure";
      };
    };
  };
}
