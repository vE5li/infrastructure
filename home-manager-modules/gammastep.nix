{...}: {
  services.gammastep = {
    enable = true;

    temperature.day = 5700;
    temperature.night = 3700;

    provider = "manual";
    latitude = 51.1;
    longitude = 10.4;

    settings = {
      general = {
        fade = 1;
        gamma = 1.0;
        adjustment-method = "wayland";
        brightness-day = 1.0;
        brightness-night = 0.7;
      };
    };
  };
}
