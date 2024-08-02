{...}: {
  programs.adb.enable = true;

  role-configuration.user.extra-groups = ["adbusers"];
}
