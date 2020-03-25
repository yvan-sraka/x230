{ config, pkgs, lib, ... }:

{
  networking.hostName = "X230"; # Define your hostname.
  # networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  networking.nameservers = [
    "2a07:a8c0::85:4ac4"
    "2a07:a8c1::85:4ac4"
    "45.90.28.69"
    "45.90.30.69"
  ]; # NextDNS

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s25.useDHCP = true;
  networking.interfaces.wlp3s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable Wireguard
  networking.wg-quick.interfaces = {
    wg0 = {
      address = [ "10.23.5.30/32" ];
      dns = [
        "2a07:a8c0::85:4ac4"
        "2a07:a8c1::85:4ac4"
        "45.90.28.69"
        "45.90.30.69"
      ]; # NextDNS
      privateKeyFile = "/etc/wireguard/private";
      peers = [{
        endpoint = "82.65.118.1:12501";
        allowedIPs = [ "10.32.64.1/20" ];
        persistentKeepalive = 25;
        publicKey = "E8tYmhZ8oR5Pdhi3u7fvvdcDvK3GOjU561gmRPkPS1Q=";
      }];
    };
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.allowedUDPPorts = [ ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # List services that you want to enable:
  programs.mosh.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  # programs.ssh.startAgent = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # I debug my network everyday.
  programs.wireshark.enable = true;
}
