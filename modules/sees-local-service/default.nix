{ config, lib, sops, inputs, pkgs, ... }:
let
  scs = inputs.sees-cloud-services.packages.${pkgs.system}.default;

  cfg = config.sees;
in
{
  options.sees.sls = with lib; with types; {
    mode = mkOption {
      type = str;
      default = "sls";
    };

    service_user = mkOption {
      type = str;
      default = "sees";
    };

    # This should be the scs package derivation above, but that appears
    # to hold some writable directories that will break later config
    app_dir = mkOption {
      type = str;
      default = cfg.sees_dir + "/Apps/sees-local-service/" + sls.version???;
    };

    cache_prefix = mkOption {
      type = str;
      default = cfg.cache_root + "/SLS";
    };

    config_root = mkOption {
      type = str;
      default = cfg.sees_dir + "/Config/sees-local-service";
    };

    # Not needed as this is handled by a nix derivation
    # If needed in a sensible place, we can always symlink it there,
    # and developers can copy it.
    #config_dir = mkOption {
    #  type = str;
    #  default = config_root + "/" + sls.version????;
    #};


    # This currently lives under the installed version of sls, which
    # is a no-no under nix.
    logs_dir = mkOption {
      type = str;
      default = app_dir + "/var/log";
    };

    # Derivation?  Appears to be built in a makefile?
    # Appears to only be used during SLS installation
    # svc_act_filename = mkOption {
    #   type = str;
    #   default = config_root + "sls.svc_account.json";
    # };

    environment = mkOption {
      type = str;
      default = "release";
    };

    px4_enabled = mkOption {
      type = bool;
      default = true;
    };

    pc_number = mkOption {
      type = str;
      default = "";
    };

    asset_access_token = mkOption {
      type = str;
      default = "";
    };

    asset_serial_number = mkOption {
      type = str;
      default = "";
    };

    is_dev_version = mkOption {
      type = bool;
      default = false;
    };

    wheel_version = mkOption {
      type = str;
      default = "";
    };

    wheel_filename = mkOption {
      type = str;
      default = "";
    };

    px4_server_host = mkOption {
      type = str;
      default = "127.0.0.1";
    };

    das_power_cmd_command_scope = mkOption {
      type = str;
      default = "system";
    };
  };

  config = 
    let
      main_config = pkgs.sees-lib.jinja "main.yml" 
        (builtins.readFile ./sls_main.yml.j2) 
        {
          app_config = app_config;
        };

      app_config = pkgs.sees-lib.jinja "app_config.yml"
        (builtins.readFile ./sls_app_config.yml.j2)
        {
          sees_interface_config = sees_interface_config;

          sls_mode = cfg.sls.mode;
          sls_asset_serial_number = cfg.sls.asset_serial_number;
          mavsdk_server_qgroundcontrol_sysid = cfg.mavsdk-server.default_sysid;
          mavsdk_server_qgroundcontrol_compid = cfg.mavsdk-server.default_compid;
          sls_px4_enabled = cfg.px4_enabled;
          sls_px4_server_host = cfg.sls.px4_server_host;
          
          sls_cache_prefix = cfg.sls.cache_prefix;
          sls_logs_dir = cfg.sls.logs_dir;
        };

      sees_interface_config = pkgs.sees-lib.jinja "sees_interface_config.yml"
        (builtins.readFile ./sls_sees_interface.yml.j2)
        {
        };
    in
    {
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
