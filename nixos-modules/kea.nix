{config, ...}: {
  services.kea.dhcp4 = {
    enable = true;

    settings = {
      # Number of seconds the DHCP lease is valid for (86400 == one day).
      valid-lifetime = 86400;

      # Only offer over ethernet.
      interfaces-config.interfaces = ["enp1s0"];

      lease-database = {
        type = "memfile";
        persist = true;
        name = "/var/lib/kea/dhcp4.leases";
      };

      subnet4 = [
        {
          # Unique ID of the subnet.
          id = 1;

          # Subnet (e.g. `192.168.188.0/24`)
          subnet = config.role-configuration.subnet;

          # Addresses which may be distributed.
          pools = [{pool = config.role-configuration.dhcp-pool;}];

          # Router and DNS setup.
          option-data = [
            {
              name = "routers";
              data = config.role-configuration.router-ip;
            }
            {
              name = "domain-name-servers";
              data = config.role-configuration.ip-address;
            }
          ];

          # Static IP addresses.
          reservations = (
            map
            (device: {inherit (device) hw-address ip-address;})
            (builtins.filter (device: device.hw-address != null) config.role-configuration.devices)
          );
        }
      ];
    };
  };
}
