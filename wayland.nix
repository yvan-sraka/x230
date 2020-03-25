{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    acpilight
    adwaita-qt
    autotiling
    clipman
    flashfocus
    gnome3.adwaita-icon-theme
    gnomeExtensions.appindicator
    grim
    rofi # TODO wofi
    slurp
    wf-recorder
    wl-clipboard
    xdg-desktop-portal-gtk
    xdg-utils
    xwayland
    # Here we but a shell script into path, which lets us start sway.service
    # (after importing the environment of the login shell).
    (pkgs.writeTextFile {
      name = "startsway";
      destination = "/bin/startsway";
      executable = true;
      text = ''
        #! ${pkgs.bash}/bin/bash
        export _JAVA_AWT_WM_NONREPARENTING=1 XKB_DEFAULT_LAYOUT="dvorak" GTK_THEME="Adwaita:dark"
        dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY
        systemctl --user import-environment # first import environment variables from the login manager
        systemctl --user start sway.service # then start the service
      '';
    })
    blender
    chromium
    discord
    dolphinEmu
    firefox
    godot
    ghidra-bin
    jetbrains.pycharm-community
    jetbrains.idea-community
    kitty
    klavaro
    obs-studio
    signal-desktop
    tdesktop
    teams
    thunderbird
    virtualbox
    vlc
    vscode
    zotero
  ];

  qt5 = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Enable GNOME Desktop.
  # services.xserver.enable = true;
  # services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true; # FIXME

  # Running ancient applications.
  services.dbus.packages = with pkgs; [ gnome2.GConf ];

  # Running GNOME programs outside of GNOME.
  programs.dconf.enable = true;

  # Systray Icons.
  services.udev.packages = with pkgs; [ gnome3.gnome-settings-daemon ];

  # Sway
  programs.sway = {
    wrapperFeatures.gtk = true;
    enable = true;
    extraPackages = with pkgs; [
      swaylock # lockscreen
      swayidle
      xwayland # for legacy apps
      mako # notification daemon
      kanshi # autorandr
      brillo # backlight
    ];
  };

  environment = {
    etc = {
      # Put config files in /etc. Note that you also can put these in ~/.config,
      # but then you can't manage them with NixOS anymore!
      "sway/config".source = ./sway.cfg;
    };
  };

  systemd.user.targets.sway-session = {
    description = "Sway compositor session";
    documentation = [ "man:systemd.special(7)" ];
    bindsTo = [ "graphical-session.target" ];
    wants = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];
  };

  systemd.user.services.sway = {
    description = "Sway - Wayland window manager";
    documentation = [ "man:sway(5)" ];
    bindsTo = [ "graphical-session.target" ];
    wants = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];
    # We explicitly unset PATH here, as we want it to be set by
    # systemctl --user import-environment in startsway
    environment.PATH = lib.mkForce null;
    serviceConfig = {
      Type = "simple";
      ExecStart = ''
        ${pkgs.dbus}/bin/dbus-run-session ${pkgs.sway}/bin/sway --debug
      '';
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  programs.waybar.enable = false; # I prefer i3status-rust :)

  systemd.user.services.kanshi = {
    description = "Kanshi output autoconfig ";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      # kanshi doesn't have an option to specifiy config file yet, so it looks
      # at .config/kanshi/config
      ExecStart = ''
        ${pkgs.kanshi}/bin/kanshi
      '';
      RestartSec = 5;
      Restart = "always";
    };
  };

  systemd.user.services.swayidle = {
    description = "Idle Manager for Wayland";
    documentation = [ "man:swayidle(1)" ];
    wantedBy = [ "sway-session.target" ];
    partOf = [ "graphical-session.target" ];
    path = [ pkgs.bash ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.swayidle}/bin/swayidle -w -d \
               timeout 300 '${pkgs.sway}/bin/swaymsg "output * dpms off"' \
               resume '${pkgs.sway}/bin/swaymsg "output * dpms on"'
             '';
    };
  };

  fonts = {
    fonts = with pkgs; [ jetbrains-mono ];
    fontconfig = {
      enable = true;
      defaultFonts.monospace = [ "JetBrains Mono" ];
    };
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # To use Flatpak you must enable XDG Desktop Portals with xdg.portal.enable.
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  services.flatpak.enable = true;

  # :')
  nixpkgs.config.allowUnfree = true;
}
