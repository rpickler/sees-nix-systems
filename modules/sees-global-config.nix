{ config, lib, sops, ... }:
{
  options.sees = with lib; with types; {
    sees_dir = mkOption {
      type = str;
      default = "/opt/sees";
    }; 
  };
}
