{
  pkgs,
  config,
  ...
}: {
  networking.firewall = {
    # Voice chat port.
    allowedUDPPorts = [24454];
    # Nginx for bluemap.
    allowedTCPPorts = [80];
  };

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;

    servers.fabric = {
      enable = true;
      jvmOpts = "-Xms2048M -Xmx8192M";

      whitelist = {
        styler1001 = "dd9df977-691b-4e97-b957-947a06d7ba89";
        bighomer70 = "fd5866e3-724e-43b3-bd13-2ee502e213f6";
      };

      serverProperties = {
        allow-flight = true;
        server-port = 25565;
        difficulty = "normal";
        gamemode = "survival";
        max-players = 20;
        motd = "Minecraft season 1!";
        white-list = true;
        allow-cheats = false;
        force-gamemode = true;
      };

      package = pkgs.fabricServers.fabric-1_21_11.override {
        # Specific fabric loader version
        loaderVersion = "0.18.4";
      };

      symlinks = {
        mods = pkgs.linkFarmFromDrvs "mods" (
          builtins.attrValues {
            Fabric-API = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/5oK85X7C/fabric-api-0.140.0%2B1.21.11.jar";
              sha512 = "sha512-8z06ptTah3l16w+BT5rIwC+WQeAZJAJEWRLdq0MmnvzGhe8U1Z/Y7lPeubb/RSFELgbh3h/RKEtCZxFATbU1Cw==";
            };
            # TODO: Remove to enable the nether and end.
            NoDim = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/PL5F9WAX/versions/iZvU0GH8/NoDim-1.3.0.jar";
              sha512 = "sha512-J3u9UYoo/mbOU9OsU9dSOsryYXOAbbBmDzPimpzHGS/zWfnrTreX9BtHTMCSkQBtSweHjQgIJAvuaVphBcIwhQ==";
            };
            SimpleVoiceChat = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/pFTZ8sqQ/voicechat-fabric-1.21.11-2.6.12.jar";
              sha512 = "sha512-r8eOPYykY/t4OwDsPUy5OP+SSfCI0Hf4zXX2yEZBng/kkWBh9XoLGIpcKFZck0YjxSET9HbmnoKuyrr/yOj9zA==";
            };
            AppleSkin = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/EsAfCjCV/versions/59ti1rvg/appleskin-fabric-mc1.21.11-3.0.8.jar";
              sha512 = "sha512-0yIGy41vrH8LV59yaSAxNXdyg+FjnMto+GBen1RptbVDBf02uoLGS0i4muTxo4UBv7WCcoRSDD7GItle3Po03g==";
            };
            BetterThanMending = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/Lvv4SHrK/versions/wHUk8xSy/BetterThanMending-2.2.5.jar";
              sha512 = "sha512-1WrMVAdRUd/U7ml6nGcHkZOFUF0ysB7ktnp9CDxej2VsalG/rDTeARvw2EVfn6P934GkXzw2vRnRpI2Gi6qn7w==";
            };
            Chunky = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/fALzjamp/versions/1CpEkmcD/Chunky-Fabric-1.4.55.jar";
              sha512 = "sha512-O+DgSePepiVrOVzLH33MycayPLex9qcXp80cpV+dvaSJZ53zKGjHJmTrsoygXyw2ZZDR4aEfDcX2n5R5A7rYMw==";
            };
            Clumps = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/Wnxd13zP/versions/oyuxjkbY/Clumps-forge-1.21.11-29.0.0.1.jar";
              sha512 = "sha512-zLjG3IlNXH36fM6n/cN/kF+WrnpfuPfz/FQRl6+RobcEIbq+FfK30MK3om/+8whRLG4fX0A40/JSo4yACiYszw==";
            };
            DistantHorizons = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/uCdwusMi/versions/GT3Bm3GN/DistantHorizons-2.4.5-b-1.21.11-fabric-neoforge.jar";
              sha512 = "sha512-qfZz+sH29VS3OUFoy+cm8aFesrvvG2WzyZeYU6+N5wvxOkV8iOvcMLlVoHHVGehsYxzb8d05zat8c7nC1/Fl4Q==";
            };
            ForgeConfigApiPort = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/ohNO6lps/versions/uXrWPsCu/ForgeConfigAPIPort-v21.11.1-mc1.21.11-Fabric.jar";
              sha512 = "sha512-KHkcmS1hPaFLhoVQXT72Mu1TtfHh1RfwtBZ30Q+EGfGS373pkTCN9s2l0PETwKqPwY7PSgg0ApQDsW0vaNxS1g==";
            };
            PuzzlesLib = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/QAGBst4M/versions/mduzHuXT/PuzzlesLib-v21.11.3-mc1.21.11-Fabric.jar";
              sha512 = "sha512-2F0wJLXEWs3byfQRTdW9fJXCCmNj/YC3DmbC9TW6xS3hCv9S71ExKN3mYnUcWdIDP/hc8Sn4wivnzm2l5sj2+g==";
            };
            EasyAnvils = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/OZBR5JT5/versions/Ti2RnQEI/EasyAnvils-v21.11.0-mc1.21.11-Fabric.jar";
              sha512 = "sha512-UwIXCCR22F0OMH3SqXftqF3K0ETuozcAiD6717OZsE85IiytJBXSWFwDn6m7tTNzBWXeS3rACHwl/DKR8M8IZg==";
            };
            EasyMagic = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/9hx3AbJM/versions/Bk567o2Y/EasyMagic-v21.11.0-mc1.21.11-Fabric.jar";
              sha512 = "sha512-e2M97ezhHDJ+iWTfoD6C0X3jtkh5bKPXKkXlk24EV1ihU2vuc3SmOgDhSOka9/matP75Uhg0OiTVLhKOnXhG+A==";
            };
            Collective = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/e0M1UDsY/versions/T8rv7kwo/collective-1.21.11-8.13.jar";
              sha512 = "sha512-rxRaSKyJNGx7H/qMREAKkamQjk0d8PbxpgP/BFsf2C2aoEGuonpoLBlrJmwNr4TLW3uNg7B+5T4rwaXCENGaGw==";
            };
            NoFeatherTrample = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/VmGOLJeH/versions/TXrIpdNs/nofeathertrample-1.21.11-1.3.jar";
              sha512 = "sha512-6opU7vHAGDizUKSELR5DBfGLwBZKun7HbGANdgE6DyVQrUDad3TYUzT8LORV1ctzPQA1sEqapBxTJrHl/BZgJA==";
            };
            TradeCycling = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/qpPoAL6m/versions/gjL3kDvK/trade-cycling-fabric-1.21.11-1.0.20.jar";
              sha512 = "sha512-9Y30WLnC1lxwZ+UU3TjxFcnFS2Mh8cAue6cFllXM8fd2Pb/JHkg2FAQQDUITtSA+DgmwWl/2BWVBkbqXCYAhTw==";
            };
            XaerosWorldMap = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/NcUtCpym/versions/CkZVhVE0/xaeroworldmap-fabric-1.21.11-1.40.11.jar";
              sha512 = "sha512-PrEiJcEIJdSIfC6RWyozG+CbbqxKdczDIHZ1QskmM9EbxqimPLKyi78GLBAuTsUAANMIKJLgAygETWIlsYNvZQ==";
            };
          }
        );
      };
    };
  };

  services.bluemap = rec {
    enable = true;
    eula = true;
    host = "/";
    defaultWorld = config.services.minecraft-servers.dataDir + "/fabric/world";

    maps = {
      "overworld" = {
        world = defaultWorld;
        ambient-light = 0.1;
      };
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts.${config.services.bluemap.host} = {
      locations = {
        "~* ^/maps/[^/]*/textures.json".extraConfig = ''
          error_page 404 = @empty;
          gzip_static always;
        '';
      };
    };
  };
}
