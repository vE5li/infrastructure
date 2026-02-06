{config, ...}: let
  domain = "grafana.${config.role-configuration.domain}";
in {
  services.prometheus = {
    enable = true;
    globalConfig.scrape_interval = "30s";
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = map (host: "${host}:${toString config.services.prometheus.exporters.node.port}") ["localhost" "computer" "vault"];
          }
        ];
      }
      {
        job_name = "esphome";
        static_configs = [
          {
            targets = [
              "controller"
              "computer-case"
            ];
          }
        ];
      }
    ];
  };

  services.grafana = {
    enable = true;
    openFirewall = true;

    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 9999;
        inherit domain;
      };
      security.secret_key = "243b6073dded8afdbca51582dc449523767780ec375aeeb2ae05f8a3680e2084";
    };
  };

  services.caddy = {
    virtualHosts.${domain}.extraConfig = ''
      reverse_proxy http://localhost:${toString config.services.grafana.settings.server.http_port}
    '';
  };
}
