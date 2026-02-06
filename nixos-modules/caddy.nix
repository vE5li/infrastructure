{
  lib,
  pkgs,
  config,
  ...
}: {
  options.role-configuration = with lib; {
    domain = mkOption {
      description = "Domain of this network";
      type = types.str;
    };
  };

  config = {
    age.secrets."caddy.env" = {
      file = ../secrets/caddy.env.age;
      mode = "770";
      owner = "caddy";
      group = "caddy";
    };

    services.caddy = {
      enable = true;

      environmentFile = config.age.secrets."caddy.env".path;

      package = pkgs.caddy.withPlugins {
        plugins = ["github.com/caddy-dns/cloudflare@v0.2.4"];
        hash = "sha256-Olz4W84Kiyldy+JtbIicVCL7dAYl4zq+2rxEOUTObxA=";
      };

      virtualHosts."*.${config.role-configuration.domain}".extraConfig = ''
        tls {
          dns cloudflare {env.CLOUDFLARE_API_TOKEN}
          resolvers 1.1.1.1 1.0.0.1
        }
      '';
    };

    networking.firewall = {
      allowedTCPPorts = [
        443
      ];
    };
  };
}
