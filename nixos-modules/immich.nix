{config, ...}: {
  services.immich = {
    enable = true;
    port = 2283;

    # Disabled for now
    machine-learning.enable = false;

    # Give Immich access to all devices.
    accelerationDevices = null;

    openFirewall = true;
  };

  # Enable Immich graphics acceleration.
  users.users.immich.extraGroups = ["video" "render"];

  role-configuration.subdomains = ["immich"];

  services.nginx.virtualHosts."immich.${config.role-configuration.host-name}.${config.role-configuration.domain}" = {
    locations."/" = {
      proxyPass = "http://localhost:${toString config.services.immich.port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
      extraConfig = ''
        client_max_body_size 50000M;
        proxy_read_timeout   600s;
        proxy_send_timeout   600s;
        send_timeout         600s;
      '';
    };
  };
}
