{
  config,
  lib,
  ...
}: {
  options.role-configuration = with lib; {
    ip-address = mkOption {
      description = "IP address of this device";
      type = types.str;
    };
    subnet = mkOption {
      description = "Network submask";
      type = types.str;
    };
    wireguard-subnet = mkOption {
      description = "WireGuard submask";
      type = types.str;
    };
    router-ip = mkOption {
      description = "Network gateway";
      type = types.str;
    };
    dhcp-pool = mkOption {
      description = "Pool of DHCP addresses to lease";
      type = types.str;
    };
    devices = mkOption {
      description = "A list of permanent devices in this network";
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            description = "Name of the device";
            type = types.str;
          };
          ip-address = mkOption {
            description = "IPv4 address of the device";
            type = types.nullOr types.str;
            default = null;
          };
          hw-address = mkOption {
            description = "Hardware address of the device. Used for static DHCP entries";
            type = types.nullOr types.str;
            default = null;
          };
          wireguard-address = mkOption {
            description = "WireGuard address of the device";
            type = types.nullOr types.str;
            default = null;
          };
          yggdrasil-address = mkOption {
            description = "Yggdrasil network address of the device";
            type = types.nullOr types.str;
            default = null;
          };
          subdomains = mkOption {
            description = "Subdomains of this device server";
            type = types.listOf types.str;
            default = [];
          };
        };
      });
    };
  };

  config = {
    # Static IP for the wired interface.
    networking.interfaces.enp1s0 = {
      # Disable DHCP since the home server itself is the DHCP server.
      useDHCP = false;

      ipv4.addresses = [
        {
          address = config.role-configuration.ip-address;
          prefixLength = 24;
        }
      ];
    };

    networking.defaultGateway = {
      address = config.role-configuration.router-ip;
      interface = "enp1s0";
    };
  };
}
