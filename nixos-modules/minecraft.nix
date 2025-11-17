{
  config,
  lib,
  ...
}: let
  minecraft-folder = "/home/lucas/allthemods10-data";

  domain = "bluemap.${config.role-configuration.domain}";
in {
  # TODO: Currently the minecraft server is started through docker but I would like to move it here.

  networking.firewall = {
    allowedTCPPorts = [25565];
  };

  services.bluemap = rec {
    enable = true;
    eula = true;
    enableNginx = false;
    host = domain;
    defaultWorld = "${minecraft-folder}/world";
    modsFolder = "${minecraft-folder}/mods";

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

  systemd.services."render-bluemap-maps".serviceConfig.Group = lib.mkForce "caddy";

  services.caddy = {
    virtualHosts.${domain}.extraConfig = ''
      root * ${config.services.bluemap.webRoot}

      route {
        @tiles path_regexp ^/maps/[^/]*/tiles/.*

        # Handle tile requests with gzip
        handle @tiles {
          rewrite * {path}.gz
          header Content-Encoding gzip
          file_server
        }

        # Handle textures.json requests with gzip
        @textures path_regexp ^/maps/[^/]*/textures\.json$
        handle @textures {
          rewrite * {path}.gz
          header Content-Encoding gzip
          file_server
        }

        file_server
      }

      handle_errors 404 {
        @tiles path_regexp ^/maps/[^/]*/tiles/.*

        handle @tiles {
          respond 204
        }
      }
    '';
  };
}
