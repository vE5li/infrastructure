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
      public-keys = mkOption {
        type = types.listOf types.str;
        default = [];
      };
    };
  };

  config = with config.role-configuration.yggdrasil; {
    age.secrets."yggdrasil-private-key.hjson".file = private-key;

    services.yggdrasil = {
      enable = true;
      configFile = config.age.secrets."yggdrasil-private-key.hjson".path;
      settings = {
        Peers = peers;
        Listen = lib.mkIf listen [
          "tcp://0.0.0.0:${toString port}"
        ];
        AllowedPublicKeys = public-keys;
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf listen [
      port
    ];
  };
}
