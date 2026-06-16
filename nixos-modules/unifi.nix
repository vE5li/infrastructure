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
      # UniFi performs two anti-CSRF checks on every authenticated request:
      #
      #  1. Origin must be in its hardcoded allowlist of *.ui.com/*.ubnt.com
      #     hosts. We rewrite the upstream Origin to a known-allowed value so
      #     UniFi accepts the request, and rewrite the CORS response header
      #     back to the browser's real origin so the browser's CORS check
      #     also passes.
      #
      #  2. Referer (if present) must match the Host UniFi sees. Caddy proxies
      #     to https://localhost:8443 and Go's default Host is "localhost:8443"
      #     for that upstream, so UniFi expects Referer to also be localhost.
      #     The browser sends Referer: https://unifi.<domain>/... which UniFi
      #     rejects with 401, causing the SPA to bounce back to the login page
      #     even though the session cookie is valid. We strip Referer to
      #     bypass this check entirely.
      reverse_proxy https://localhost:8443 {
        transport http {
          tls_insecure_skip_verify
        }
        header_up Origin "https://unifi.ui.com"
        header_up -Referer
        header_down Access-Control-Allow-Origin "https://unifi.${config.role-configuration.domain}"
      }
    '';
  };
}
