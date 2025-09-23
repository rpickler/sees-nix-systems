{ config, lib, ... }:
{
  config = lib.mkIf config.disable-screensaver {
    services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
      org.gnome.desktop.screensaver.lock-enabled=false
      org.gnome.desktop.session.idle-delay=0
    '';
  };
}

