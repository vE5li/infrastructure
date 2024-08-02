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
    domain = mkOption {
      default = "home";
      description = "Domain of this network";
      type = types.str;
    };
    subnet = mkOption {
      description = "Network submask";
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
    subdomains = mkOption {
      description = "Subdomains of the central server";
      type = types.listOf types.str;
      default = [];
    };
    devices = mkOption {
      description = ''
        A list of permanent devices in this network.
        A device takes `name` and `ip-address` to set up a DNS entry.
        Additionally `hw-address` to give the device a static DHCP entry.
      '';
      type = types.listOf types.attrs;
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
