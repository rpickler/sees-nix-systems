{ config, lib, pkgs, ... }:
let
  cfg = config.core-dump-tracker;
in
{
  options.core-dump-tracker = with lib; with types; {
    dir = mkOption {
      type = str;
      default = "";
    };
  };

  config = lib.mkIf (cfg.dir != "") {
    boot.kernel.sysctl."kernel.core_pattern" = "${cfg.core_dump_dir}/core-%e.%p.%h.%t";
  };
}
