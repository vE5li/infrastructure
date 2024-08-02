{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    spotify
  ];

  hardware.bluetooth.enable = true;
}
