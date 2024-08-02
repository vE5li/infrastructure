{...}: {
  # Make esp home secrets readable.
  users.groups.esphome = {};

  age.secrets."esphome-secrets.yaml" = {
    file = ../secrets/esphome-secrets.yaml.age;
    mode = "0640";
    group = "esphome";
  };

  role-configuration.user.extra-groups = ["esphome"];
}
