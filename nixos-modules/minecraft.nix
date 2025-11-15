{...}: {
  # TODO: Currently the minecraft server is started through docker but I would like to move it here.

  networking.firewall = {
    allowedTCPPorts = [25565];
  };

  role-configuration.subdomains = ["bluemap"];

  services.bluemap = rec {
    enable = true;
    eula = true;
    defaultWorld = "/home/lucas/allthemods10-data/world";
    host = "bluemap.central.home";
    modsFolder = "/home/lucas/allthemods10-data/mods";

    maps = {
      "overworld" = {
        world = defaultWorld;
        ambient-light = 0.1;
      };

      "nether" = {
        world = defaultWorld;
        dimension = "minecraft:the_nether";
        ambient-light = 0.6;
        world-sky-light = 0;
        remove-caves-below-y = -10000;
        cave-detection-ocean-floor = -5;
        cave-detection-uses-block-light = true;
        remove-nether-ceiling = true;
      };
    };
  };

  # Bluemap also compresses the textures.json so we need to add a rule do decompress it.
  services.nginx.virtualHosts."bluemap.central.home" = {
    locations = {
      "~* ^/maps/[^/]*/textures.json".extraConfig = ''
        error_page 404 = @empty;
        gzip_static always;
      '';
    };
  };
}
