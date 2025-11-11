{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    yaak
    slack
    google-chrome
    claude-code
  ];

  networking.firewall.allowedTCPPorts = [
    3000
  ];
}
