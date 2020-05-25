
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  networking = {
    useDHCP = false;
    interfaces.enp0s25.useDHCP = true;
    interfaces.wlp2s0.useDHCP = true;
    firewall.allowedTCPPorts = [
      3000 # grafana
      9090 # prometheus
      9100 # node exporter
    ];
  };

  time.timeZone = "America/Chicago";

  environment.systemPackages = with pkgs; [
    grafana
    jq
    mkpasswd
    prometheus
    neovim
    wget
  ];

  services.openssh.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.envmonitor = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    password = "...";
    openssh.authorizedKeys.keys = [
        ".."
     ];
  };

  system.stateVersion = "20.03";

  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = [
      "logind"
      "systemd"
    ];
    disabledCollectors = [
      "textfile"
    ];
    openFirewall = true;
    firewallFilter = "-i br0 -p tcp -m tcp --dport 9100";
  };

  services.prometheus = {
    enable = true;
    scrapeConfigs = [
      {
        job_name = "node";
        scrape_interval = "10s";
        static_configs = [
          {
            targets = ["localhost:9100"];
            labels = {
              alias = "prom-machine";
            };
          }
        ];
      }
      {
        job_name = "office environ";
        scrape_interval = "5s";
        static_configs = [
          {
            targets = ["192.168.10.129:8080"];
            labels = {
              alias = "aarons-office";
            };
          }
        ];
      }
    ];
  };

  services.grafana = {
    enable = true;
    addr = "0.0.0.0";
    domain = "192.168.10.151:3000";
    rootUrl = "http://192.168.10.151:3000/";
  };
}
