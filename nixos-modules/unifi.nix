{
  pkgs,
  config,
  ...
}: {
  services.unifi = {
    enable = true;
    openFirewall = true;
    # The default MongoDB package does not include pre-compiled binaries, so we use one that does.
    mongodbPackage = pkgs.mongodb-ce;
  };

  # Open and forward the web interface.
  networking.firewall = {
    allowedTCPPorts = [8443];
  };

  services.caddy = {
    virtualHosts."unifi.${config.role-configuration.domain}".extraConfig = ''
      reverse_proxy https://localhost:8443 {
        transport http {
          tls_insecure_skip_verify
        }
      }
    '';
  };
}
