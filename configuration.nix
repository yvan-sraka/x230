# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports = [ # Include the results of the hardware scan.
    <nixos-hardware/lenovo/thinkpad/x230>
    ./hardware-configuration.nix

    ./devtools.nix
    ./network.nix
    ./wayland.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Use the systemd-boot EFI boot loader.
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  boot.cleanTmpDir = true; # clean up /tmp during boot

  boot.kernel.sysctl = { "fs.inotify.max_user_watches" = "524288"; };

  # Do the garbage collection & optimisation daily.
  nix.gc.automatic = true;
  nix.optimise.automatic = true;

  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "dvorak";

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.yvan = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  services.earlyoom.enable = true; # License to kill.

  # I want to login with my yubikey.
  security.pam.u2f.enable = true;
  security.pam.services.login.u2fAuth = true;

  # From https://nixos.wiki/wiki/OSX-KVM
  # this is needed to get a bridge with DHCP enabled
  virtualisation.libvirtd.enable = true;
  users.extraUsers.yvan.extraGroups = [ "libvirtd" ];
  # reboot your computer after adding those lines
  boot.extraModprobeConfig = ''
    options kvm_intel nested=1
    options kvm_intel emulate_invalid_guest_state=0
    options kvm ignore_msrs=1
  '';

  # Power management
  environment.systemPackages = with pkgs; [ powertop acpi ];
  services.upower.enable = true;
  services.tlp.enable = false; # FIXME
  services.thermald.enable = true;
  powerManagement.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?
}
