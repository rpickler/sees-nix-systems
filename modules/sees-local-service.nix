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
    };

    das_power_command_scope = mkOption {
    };
  };

  config = 
    let
      scs = inputs.sees-cloud-services.packages.${pkgs.system}.default;

      config = {
        main = {
          app_config = "!include ${app_config}";
        };

        app = {
          mode = "${cfg.sls.mode}";
          host_commands_scope = "${cfg.sls.das_power_command_scope}";
          connection = {
            server = {
              host = "${cfg.scs.domain_name}";
              port = 443;
              secure = "yes";
            };
            access_token = ""; # TODO:
            retry_delay_max = 32;
            retry_delay_gain = 2;
          };

          asset = {
            serial_number = ""; # TODO:
          };

          sees_interface = "!include ${sees_interface_config}";

          
          #px4_monitor:
          #  tcp_url: "tcp:localhost:5760"
          #  source_system: {{ mavsdk_server_qgroundcontrol_sysid }}
          #  source_component: {{ mavsdk_server_qgroundcontrol_compid }}
          #  mavsdk_server_address: "{{ sls_px4_server_host }}"
          #  auto_query_interval: 5s
          #  connect_timeout: 10s
          #  command_timeout: 5s
          #
          #rams_monitor:
          #  das_server:
          #    bind_addr: 0.0.0.0
          #    bind_port: {{ sls_das_server_port }}
          #
          #    log_client_messages: false
          #
          #  rams_client:
          #    addr: {{ sls_das_rams_addr }}
          #    port: {{ sls_das_rams_port }}
          #
          #    comms_timeout: 5s
          #    log_client_messages: false
          #
          #    ws_open_timeout: 1s
          #    ws_ping_interval: 5s
          #    ws_ping_timeout: 5s
          #    ws_close_timeout: 1s
          #
          #    ws_encoding: {{ sls_das_ws_encoding }}
          #
          #  sftp_server:
          #    host: {{ sls_das_server_addr }}
          #    port: {{ sls_das_sftp_port }}
          #
          #  survey_data:
          #    export_format: json
          #    export_filename: SurveyData
          #
          #  power_commands_scope: {{ sls_das_power_cmd_scope }}
          #
          #          
          #uploads:
          #  upload_chunk_size: 16MiB
          #
          #          
          #caching:
          #  prefix: "{{ sls_cache_prefix }}"
          #
          #logging:
          #  formatters:
          #    # Default formatter used for pretty much every logger.
          #    default: {}
          #
          #  handlers:
          #    # Standard handler: output everything to STDOUT.
          #    terminal:
          #      class: logging.StreamHandler
          #      level: INFO
          #      formatter: default
          #
          #    log_file:
          #      class: logging.handlers.TimedRotatingFileHandler
          #      level: DEBUG
          #      formatter: default
          #      filename: "{{ sls_logs_dir }}/sees-local-service.log"
          #      backupCount: 30
          #      when: midnight
          #
          #    # Specific handler to inhibit SI2 output to not clutter STDOUT.
          #    si2_null:
          #      class: logging.NullHandler
          #
          #  loggers:
          #    # Root logger to which (almost) every other logger should propagate.
          #    "":
          #      level: DEBUG
          #      handlers:
          #        - terminal
          #        - log_file
          #
          #    # Specific logger for SI2 (once launched). This shouldn't propagate to reduce STDOUT clutter.
          #    "SI2Monitor:App":
          #      propagate: false
          #      handlers:
          #        - si2_null
          #
          #    # Specific configuration for loggers from third-party libraries.
          #    "watchdog":
          #      level: WARNING
          #    "watchfiles.main":
          #      level: WARNING
          #    "mavsdk.async_plugin_manager":
          #      level: ERROR
          #    "mavsdk.system":
          #      level: ERROR
          #    "sees.mavlink":
          #      level: ERROR
          #    "asyncio":
          #      level: CRITICAL
          #    "websockets.client":
          #      level: CRITICAL
          #    "websockets.server":
          #      level: CRITICAL
          #    "asyncssh":
          #      level: WARNING
          #    "asyncssh.sftp":
          #      level: WARNING
          #    "urllib3":
          #      level: WARNING
        };
          #
        sees_interface = {
          #
          ## Pick a specific app config to launch SeesInterface2 with
          #program: "{{ sls_si2_program }}"
          #root_dir: "{{ sls_si2_root_dir }}"
          #log_path:
          #  SeesInterface2: "{{ sls_si2_log_path }}"
          #  SeesLocalService: "{{ sls_logs_dir }}"
          #environment:
          #{%- if sls_si2_library_path +%}
          #  LD_LIBRARY_PATH: "{{ sls_si2_library_path | join(':') }}"
          #{% endif %}
          #{%- if sls_si2_preload +%}
          #  LD_PRELOAD: "{{ sls_si2_preload | join(':') }}"
          #{% endif %}
          #{%+ if sls_si2_args +%}
          #args:
          #{%+ for arg in sls_si2_args %}
          #  - {{ arg }}
          #{% endfor %}
          #{% endif %}
          #
          ## Terminal output is captured in a ring buffer to send to the Cloud Services. This defines how
          ## large that ring buffer is
          #max_output_lines: 1_000
          #
          ## Allow SI2 plenty of time to close down
          #sigint_timeout: 15s

        };
      };

      yaml = pkgs.formats.yaml {};

      main_config = yaml.generate "main.yml" config.main;
      app_config = yaml.generate "app_config.yml" config.app;
      sees_interface_config = yaml.generate "sees_interface_config.yml" config.sees_interface;
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
