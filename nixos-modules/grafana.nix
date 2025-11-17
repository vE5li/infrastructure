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
    };
  };

  services.caddy = {
    virtualHosts.${domain}.extraConfig = ''
      reverse_proxy http://localhost:${toString config.services.grafana.settings.server.http_port}
    '';
  };
}
