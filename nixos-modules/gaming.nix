{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    wine
    lutris
    # Minecraft
    prismlauncher
    osu-lazer-bin
    factorio
  ];

  # Tablet for osu!
  hardware.opentabletdriver.enable = true;
  boot.blacklistedKernelModules = [
    "wacom"
    "hid_uclogic"
  ];
}
