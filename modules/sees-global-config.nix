{ config, lib, sops, ... }:
{
  options.sees = with lib; with types; {
    sees_dir = mkOption {
      type = str;
      default = "/opt/sees";
    }; 
    domain_name = mkOption {
      type = str;
      default = "cloud.sees.ai";
    };
  };

  config = {
    users.users.sees = {
      isNormalUser = true;
      description = "Sees";
      extraGroups = [ "video" ];
      hashedPassword = "$y$j9T$F6znuPxw3tierSw.Y7iN81$VliUP9TzDQOg5UIB0NTJoSDTfwodGkU2lOvMPWMt1K4";
    };
  };

}
