{
  config,
  lib,
  ...
}: let
  listen = config.role-configuration.yggdrasil.port != null;
in {
  options.role-configuration = with lib; {
    yggdrasil = {
      peers = mkOption {
        type = types.listOf types.str;
        default = [];
      };
      private-key = mkOption {
        type = types.pathInStore;
      };
      port = mkOption {
        description = "Central Yggdrasil node port";
        type = types.nullOr types.port;
        default = null;
      };
    };
  };

  config = {
    age.secrets.yggdrasil-private-key.file = config.role-configuration.yggdrasil.private-key;

    services.yggdrasil = {
      enable = true;
      configFile = config.age.secrets.yggdrasil-private-key.path;
      settings = {
        Peers = config.role-configuration.yggdrasil.peers;
        Listen = lib.mkIf listen [
          "tcp://0.0.0.0:${builtins.toString config.role-configuration.yggdrasil.port}"
        ];
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf listen [
      config.role-configuration.yggdrasil.port
    ];
  };
}
