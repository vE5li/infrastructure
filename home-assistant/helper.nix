{lib, ...}: rec {
  # HACK: to support !secret syntax. Ideally this can be solved in a nicer fashion.
  ssid-secret = 32123456789;
  password-secret = 98123456789;
  to-yaml = config: builtins.replaceStrings [(toString ssid-secret)] ["!secret wifi_name"] (builtins.replaceStrings [(toString password-secret)] ["!secret wifi_password"] (lib.generators.toYAML {} config));
}
