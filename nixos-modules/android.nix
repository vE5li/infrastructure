{pkgs, ...}: {
  programs.adb.enable = true;

  environment.systemPackages = [pkgs.android-studio];

  role-configuration.user.extra-groups = ["adbusers"];
}
