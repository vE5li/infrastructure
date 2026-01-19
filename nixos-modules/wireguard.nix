{
  pkgs,
  lib,
  config,
  ...
}: {
  options.role-configuration.wireguard = with lib; {
    private-key = mkOption {
      type = types.pathInStore;
    };
    interface-name = mkOption {
      description = "WireGuard interface name";
      type = types.str;
      default = "wireguard-home";
    };
    port = mkOption {
      description = "WireGuard listen port";
      type = types.port;
    };
    ip-forward = mkEnableOption {
      description = "net.ipv4.ip_forward";
    };
    nat-interface = mkOption {
      description = "NAT external interface";
      type = types.nullOr types.str;
      default = null;
    };
    explicit-route = mkOption {
      description = "Disable route table and default gateway and instead define a route manually";
      type = types.nullOr types.str;
      default = null;
    };
    open-firewall = mkEnableOption {
      description = "Open the firewall";
    };
    trusted-interfaces = mkOption {
      description = "Trusted interfaces. If this is not null, the WireGuard network will be trusted too.";
      type = types.nullOr (types.listOf types.str);
      default = null;
    };
    address = mkOption {
      description = "IPv4 address with CIDR notation";
      type = types.nullOr types.str;
      default = null;
    };
    peers = mkOption {
      description = "WireGuard peers. The name is the private-key";
      type = types.attrs;
    };
  };

  config = with config.role-configuration.wireguard; {
    environment.systemPackages = with pkgs; [
      wireguard-tools
    ];

    networking.wireguard.enable = true;

    boot.kernel.sysctl."net.ipv4.ip_forward" = lib.mkIf ip-forward 1;

    networking.firewall.allowedUDPPorts = lib.mkIf open-firewall [port];
    networking.firewall.trustedInterfaces = lib.mkIf (trusted-interfaces != null) ([interface-name] ++ trusted-interfaces);

    networking.nat = lib.mkIf (nat-interface != null) {
      enable = true;
      internalInterfaces = [interface-name];
      externalInterface = nat-interface;
    };

    age.secrets."wireguard-private-key.env".file = private-key;
    networking.networkmanager.ensureProfiles.environmentFiles = [config.age.secrets."wireguard-private-key.env".path];

    networking.networkmanager.ensureProfiles.profiles.${interface-name} =
      {
        connection = {
          inherit interface-name;
          id = interface-name;
          type = "wireguard";
          autoconnect = true;
        };

        ipv4 =
          {
            method =
              if address == null
              then "disabled"
              else "manual";
          }
          // lib.optionalAttrs (address != null) {
            inherit address;
          }
          // lib.optionalAttrs (explicit-route != null) {
            route1 = explicit-route;
            never-default = true;
          };

        ipv6.method = "disabled";

        wireguard =
          {
            private-key = "$PRIVATE_KEY";
            listen-port = port;
          }
          // lib.optionalAttrs (explicit-route != null) {
            route-table = "off";
          };
      }
      // lib.mapAttrs' (public-key: value: lib.nameValuePair "wireguard-peer.${public-key}" value) peers;
  };
}
