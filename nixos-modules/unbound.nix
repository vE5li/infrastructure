{
  config,
  lib,
  ...
}: {
  services.unbound = {
    enable = true;

    settings = {
      server = {
        # Interfaces to listen on.
        interface = ["0.0.0.0"];

        # Allowed clients.
        access-control = [
          "127.0.0.1 allow"
          "${config.role-configuration.subnet} allow"
          "${config.role-configuration.wireguard-subnet} allow"
        ];

        # Number of threads to create to serve clients.
        num-threads = 4;

        # Prefetch entries before they expire. Increases traffic and load
        # on the server but makes lookup faster for clients (I think).
        prefetch = true;

        # Refuse ‘id.server’ and ‘hostname.bind’ queries.
        hide-identity = true;
        # Refuse ‘version.server’ and ‘version.bind’ queries.
        hide-version = true;

        # Local zones.
        local-zone = [
          ''"home." static''
          ''"wireguard." static''
          ''"yggdrasil." static''
        ];

        # Local DNS entries.
        local-data = let
          inherit (config.role-configuration) domain devices;

          # Devices with a local IPv4 address.
          unchecked-home-devices = builtins.filter (device: device.ip-address != null) devices;

          # WireGuard devices.
          wireguard-devices = builtins.filter (device: device.wireguard-address != null) devices;

          # Yggdrasil devices.
          yggdrasil-devices = builtins.filter (device: device.yggdrasil-address != null) devices;

          # Create an error message for duplicate IP addresses.
          grouped = builtins.groupBy (device: device.ip-address) unchecked-home-devices;
          duplicates = lib.filterAttrs (_: devices: builtins.length devices > 1) grouped;
          error-message =
            duplicates
            |> lib.concatMapAttrsStringSep "\n" (ip-address: device: "Dulplicate IP for devices ${builtins.concatStringsSep ", " (map (device: device.name) device)}: ${ip-address}");

          # Assert that there are no duplicates.
          home-devices =
            if builtins.stringLength error-message == 0
            then unchecked-home-devices
            else throw error-message;

          # Subdomains
          subdomains =
            home-devices
            |> map
            (
              device:
                device.subdomains
                |> map (subdomain: {
                  inherit (device) ip-address;
                  domain = "${subdomain}.${domain}";
                })
            )
            |> lib.flatten;
        in
          []
          # IP records for local devices (e.g. `foo.home.` -> `192.168.188.30`).
          ++ (map (device: ''"${device.name}.home. IN A ${device.ip-address}"'') home-devices)
          # IP records for devices name (e.g. `foo.` -> `192.168.188.30`).
          ++ (map (device: ''"${device.name}. IN A ${device.ip-address}"'') home-devices)
          # IP records for WireGuard (e.g. `foo.wireguard.` -> `10.0.0.1`).
          ++ (map (device: ''"${device.name}.wireguard. IN A ${device.wireguard-address}"'') wireguard-devices)
          # IP records for Yggdrasil (e.g. `foo.yggdrasil.` -> `200:4768:2984:14a7:ae0f:74d6:e4a9:8ef0`).
          ++ (map (device: ''"${device.name}.yggdrasil. IN AAAA ${device.yggdrasil-address}"'') yggdrasil-devices)
          # IP records for Subdomains (e.g. `nextcloud.domain.com.` -> `192.168.188.30`).
          ++ (map (subdomain: ''"${subdomain.domain}. IN A ${subdomain.ip-address}"'') subdomains);
      };

      forward-zone = [
        {
          # Forward everything that is not local or cached.
          name = ".";
          forward-addr = [
            "1.1.1.1@853#cloudflare-dns.com"
            "1.0.0.1@853#cloudflare-dns.com"
            "86.54.11.100"
          ];
          forward-tls-upstream = true;
        }
      ];
    };
  };

  # Open DNS ports.
  networking.firewall = {
    allowedTCPPorts = [53];
    allowedUDPPorts = [53];
  };
}
