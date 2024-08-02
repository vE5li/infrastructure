{...}: {
  virtualisation.docker.enable = true;

  role-configuration.user.extra-groups = ["docker"];
}
