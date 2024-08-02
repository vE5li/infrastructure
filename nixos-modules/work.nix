{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    slack
    google-chrome
    claude-code
  ];

  networking.firewall.allowedTCPPorts = [
    3000
  ];
}
