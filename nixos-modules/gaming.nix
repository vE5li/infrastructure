{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    wine
    # lutris
    # Minecraft
    prismlauncher
    osu-lazer-bin
    # factorio
  ];

  hardware.ckb-next.enable = true;

  # Tablet for osu!
  hardware.opentabletdriver.enable = true;
  boot.blacklistedKernelModules = [
    "wacom"
    "hid_uclogic"
  ];
}
