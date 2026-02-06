{pkgs, ...}: {
  environment.systemPackages = [pkgs.android-tools pkgs.android-studio];

  role-configuration.user.extra-groups = ["adbusers"];
}
