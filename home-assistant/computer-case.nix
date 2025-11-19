{
  lib,
  pkgs,
  config,
  ...
}: let
  base = import ./base.nix {inherit lib pkgs config;};
in (base.build {
  esphome.name = "computer-case";
  wifi.use_address = "192.168.188.86";

  output = [
    {
      platform = "gpio";
      pin = "GPIO5";
      id = "power_button_relay";
    }
  ];

  switch = [
    {
      platform = "gpio";
      pin = "GPIO4";
      id = "lighting_relay";
      name = "Lighting";
      icon = "mdi:led-on";
    }
  ];

  button = [
    {
      platform = "output";
      name = "Power Button";
      output = "power_button_relay";
      duration = "250ms";
    }
  ];

  binary_sensor = [
    {
      platform = "gpio";
      pin = "GPIO15";
      name = "Power LED";
    }
  ];
})
