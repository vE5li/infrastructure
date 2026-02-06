{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    slack
    google-chrome
  ];

  networking.firewall.allowedTCPPorts = [
    3000
  ];
}
