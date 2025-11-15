{
  config,
  lib,
  pkgs,
  ...
}: let
  devices = config.role-configuration.devices;

  device-info =
    map (device: {
      name = device.name;
      ip = device.ip-address;
    })
    (builtins.filter (device: builtins.hasAttr "ip-address" device) devices);

  yggdrasil-device-info = map (device: {
    name = "${device.name}.yggdrasil";
    ip = device.yggdrasil-address;
  }) (builtins.filter (device: builtins.hasAttr "yggdrasil-address" device) devices);

  device-json = pkgs.writeText "devices.json" (
    lib.strings.toJSON
    {devices = device-info ++ yggdrasil-device-info;}
  );
in {
  services.healthy = {
    enable = true;
    configFile = device-json;
    openFirewall = true;
  };

  role-configuration.subdomains = ["healthy"];

  services.nginx = {
    enable = true;

    virtualHosts."healthy.${config.role-configuration.host-name}.${config.role-configuration.domain}" = {
      locations."/" = {
        proxyPass = "http://localhost:${toString config.services.healthy.port}";
      };
    };
  };
}
