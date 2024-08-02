{
  description = "My home infrastructure";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-github-actions.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.home-manager.follows = "home-manager";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colors = {
      url = "github:misterio77/nix-colors";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    neovim = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cross-cursor = {
      url = "github:ve5li/cross-cursor";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wallpapers = {
      url = "github:ve5li/wallpapers";
      flake = false;
    };

    rathena = {
      url = "github:ve5li/korangar-rathena/46cf0e1abb592c2e954b3165379ffbf41fe583ba";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    jovian-nixos = {
      url = "github:Jovian-Experiments/Jovian-NixOS/f6483fb735869c01592db599c767fa77177bb3ad";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Transitive dependencies to allow following
    systems = {
      url = "github:nix-systems/default-linux";
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
  };

  outputs = {
    self,
    nixpkgs,
    colmena,
    agenix,
    home-manager,
    neovim,
    nix-colors,
    cross-cursor,
    wallpapers,
    rathena,
    jovian-nixos,
    ...
  }: let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
    };

    nixpkgs-steam-deck = {
      system = "x86_64-linux";
      overlays = [jovian-nixos.overlays.default];
    };

    nixpkgs-korangar-rathena = {
      system = "x86_64-linux";
      overlays = [rathena.overlays.default];
    };

    central-ip-address = "192.168.188.10";

    yggdrasil-port = 1660;
    central-yggdrasil-peer = [
      "tcp://${central-ip-address}:${builtins.toString yggdrasil-port}"
    ];

    devices = {
      computer = {
        user-name = "lucas";
        ssh-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAOm6N5yWnfKUMWRcElG10ZUyLHZhNX4FMehU0uJxuQE lucas@computer";
        host-name = "computer";
        trusted = true;
      };
      laptop = {
        user-name = "lucas";
        ssh-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPeSt7pGQH4h5Pm4DJO7S3BXkOHLl6PoKeRvC9bdY5DT lucas@laptop";
        host-name = "laptop";
        trusted = true;
      };
      steam-deck = {
        user-name = "lucas";
        ssh-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILU1EGDrMsYg09X24K2oHi8Crr7PrXPtbH3Re4Qi4k+o lucas@steam-deck";
        host-name = "steam-deck";
        trusted = true;
      };
      korangar-rathena = {
        user-name = "lucas";
        ssh-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICcNaK4heuRKxBQ++REx9rEaiwBOtLobLqu2RX5MCCOq lucas@korangar-rathena";
        host-name = "korangar-rathena";
        trusted = false;
      };
      central = {
        user-name = "lucas";
        ssh-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINxrVu1aTI1If3xBIdCtnOm7z7+KCyWBUfFai9iH9WO5 ve5li@tuta.io";
        host-name = "central";
        trusted = false;
      };
    };

    device-list = builtins.attrValues devices;

    suggested-for-device = host-name:
      map (device: "${device.user-name}@${device.host-name}${pkgs.lib.optionalString device.trusted ".yggdrasil"}") (builtins.filter (device: device.host-name != host-name) device-list);

    authorized-keys-for-device = host-name:
      map (device: device.ssh-key) (builtins.filter (device: device.host-name != host-name && device.trusted) device-list);
  in {
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;

    # Dev shell to make colmena and agenix available.
    # This is nicer than installing colmena on the machine because it avoids mismatches between the installed colmena version and a potential newer one.
    devShells.x86_64-linux.default = pkgs.mkShell {
      buildInputs = [
        agenix.packages.x86_64-linux.default
        colmena.packages.x86_64-linux.colmena
      ];
    };

    colmenaHive = colmena.lib.makeHive self.outputs.colmena;

    colmena = rec {
      meta.nixpkgs = pkgs;

      defaults = {
        imports = [
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
        ];

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          sharedModules = [];

          extraSpecialArgs = {
            inherit neovim nix-colors cross-cursor;
          };
        };
      };

      #  ________/\\\\\\\\\__________________________________________________________________________________________________________
      #   _____/\\\////////___________________________________________________________________________________________________________
      #    ___/\\\/_______________________________________________/\\\\\\\\\____________________/\\\___________________________________
      #     __/\\\_________________/\\\\\_______/\\\\\__/\\\\\____/\\\/////\\\__/\\\____/\\\__/\\\\\\\\\\\_____/\\\\\\\\___/\\/\\\\\\\__
      #      _\/\\\_______________/\\\///\\\___/\\\///\\\\\///\\\_\/\\\\\\\\\\__\/\\\___\/\\\_\////\\\////____/\\\/////\\\_\/\\\/////\\\_
      #       _\//\\\_____________/\\\__\//\\\_\/\\\_\//\\\__\/\\\_\/\\\//////___\/\\\___\/\\\____\/\\\_______/\\\\\\\\\\\__\/\\\___\///__
      #        __\///\\\__________\//\\\__/\\\__\/\\\__\/\\\__\/\\\_\/\\\_________\/\\\___\/\\\____\/\\\_/\\__\//\\///////___\/\\\_________
      #         ____\////\\\\\\\\\__\///\\\\\/___\/\\\__\/\\\__\/\\\_\/\\\_________\//\\\\\\\\\_____\//\\\\\____\//\\\\\\\\\\_\/\\\_________
      #          _______\/////////_____\/////_____\///___\///___\///__\///___________\/////////_______\/////______\//////////__\///__________
      computer = with devices.computer; {
        deployment = {
          tags = ["home"];
          targetHost = "${host-name}.yggdrasil";
        };

        # NixOS modules and config
        imports = [
          ./hardware-configuration/computer.nix
          ./nixos-modules/base.nix
          ./nixos-modules/yggdrasil.nix
          ./nixos-modules/udev-embedded.nix
          ./nixos-modules/audio.nix
          ./nixos-modules/sway.nix
          ./nixos-modules/docker.nix
          ./nixos-modules/wireshark.nix
          ./nixos-modules/adb.nix
          ./nixos-modules/steam.nix
          ./nixos-modules/music.nix
          ./nixos-modules/3dprinting.nix
          ./nixos-modules/gaming.nix
          ./nixos-modules/work.nix
        ];

        role-configuration = {
          inherit host-name user-name;
          grub.resolution = "3840x1080";
          deployment-key = devices.central.ssh-key;
          authorized-keys = authorized-keys-for-device host-name;

          yggdrasil = {
            private-key = ./secrets/computer-yggdrasil-private-key.age;
            peers = central-yggdrasil-peer;
          };
        };

        # home-manager modules and config
        home-manager.users.${user-name} = {
          imports = [
            ./home-manager-modules/base.nix
            ./home-manager-modules/sway.nix
            ./home-manager-modules/gammastep.nix
            ./home-manager-modules/rofi.nix
            ./home-manager-modules/foot.nix
            ./home-manager-modules/firefox.nix
            ./home-manager-modules/handlr.nix
            ./home-manager-modules/dunst.nix
            ./home-manager-modules/nextcloud.nix
          ];

          role-configuration = {
            inherit user-name;
            git.sign-commits = true;
            suggested-remote-machines = suggested-for-device host-name;
            wallpaper = "${wallpapers}/korangar_colorful.png";
          };
        };
      };

      #   __       ________   ______   _________  ______   ______
      #  /_/\     /_______/\ /_____/\ /________/\/_____/\ /_____/\
      #  \:\ \    \::: _  \ \\:::_ \ \\__.::.__\/\:::_ \ \\:::_ \ \
      #   \:\ \    \::(_)  \ \\:(_) \ \  \::\ \   \:\ \ \ \\:(_) \ \
      #    \:\ \____\:: __  \ \\: ___\/   \::\ \   \:\ \ \ \\: ___\/
      #     \:\/___/\\:.\ \  \ \\ \ \      \::\ \   \:\_\ \ \\ \ \
      #      \_____\/ \__\/\__\/ \_\/       \__\/    \_____\/ \_\/
      laptop = with devices.laptop; {
        deployment = {
          tags = ["home"];
          targetHost = "${host-name}.yggdrasil";
        };

        # NixOS modules and config
        imports = [
          ./hardware-configuration/laptop.nix
          ./nixos-modules/base.nix
          ./nixos-modules/yggdrasil.nix
          ./nixos-modules/udev-embedded.nix
          ./nixos-modules/audio.nix
          ./nixos-modules/sway.nix
          ./nixos-modules/docker.nix
          ./nixos-modules/wireshark.nix
          ./nixos-modules/adb.nix
          ./nixos-modules/steam.nix
          ./nixos-modules/music.nix
          ./nixos-modules/3dprinting.nix
          ./nixos-modules/gaming.nix
          ./nixos-modules/work.nix
        ];

        role-configuration = {
          inherit host-name user-name;
          deployment-key = devices.central.ssh-key;
          authorized-keys = authorized-keys-for-device host-name;

          yggdrasil = {
            private-key = ./secrets/laptop-yggdrasil-private-key.age;
            peers = central-yggdrasil-peer;
          };
        };

        # home-manager modules and config
        home-manager.users.${user-name} = {
          imports = [
            ./home-manager-modules/base.nix
            ./home-manager-modules/sway.nix
            ./home-manager-modules/gammastep.nix
            ./home-manager-modules/rofi.nix
            ./home-manager-modules/foot.nix
            ./home-manager-modules/firefox.nix
            ./home-manager-modules/handlr.nix
            ./home-manager-modules/dunst.nix
            ./home-manager-modules/nextcloud.nix
          ];

          role-configuration = {
            inherit user-name;
            git.sign-commits = true;
            suggested-remote-machines = suggested-for-device host-name;
            wallpaper = "${wallpapers}/korangar_synth.png";
          };
        };
      };

      #   ___  ____  ___   __   __  __    ___  ___   __  _ _
      #  / __)(_  _)(  _) (  ) (  \/  )  (   \(  _) / _)( ) )
      #  \__ \  )(   ) _) /__\  )    (    ) ) )) _)( (_  )  \
      #  (___/ (__) (___)(_)(_)(_/\/\_)  (___/(___) \__)(_)\_)
      #
      steam-deck = with devices.steam-deck; {
        nixpkgs = nixpkgs-steam-deck;

        deployment = {
          tags = ["home"];
          targetHost = "${host-name}.yggdrasil";
        };

        # NixOS modules and config
        imports = [
          ./hardware-configuration/steam-deck.nix
          ./nixos-modules/base.nix
          ./nixos-modules/yggdrasil.nix
          ./nixos-modules/audio.nix
          ./nixos-modules/sway.nix
          ./nixos-modules/docker.nix
          ./nixos-modules/wireshark.nix
          ./nixos-modules/music.nix
          ./nixos-modules/gaming.nix
          jovian-nixos.nixosModules.default
        ];

        role-configuration = {
          inherit host-name user-name;
          deployment-key = devices.central.ssh-key;
          authorized-keys = authorized-keys-for-device host-name;

          yggdrasil = {
            private-key = ./secrets/steam-deck-yggdrasil-private-key.age;
            peers = central-yggdrasil-peer;
          };
        };

        # home-manager modules and config
        home-manager.users.${user-name} = {
          imports = [
            ./home-manager-modules/base.nix
            ./home-manager-modules/sway.nix
            ./home-manager-modules/gammastep.nix
            ./home-manager-modules/rofi.nix
            ./home-manager-modules/foot.nix
            ./home-manager-modules/firefox.nix
            ./home-manager-modules/handlr.nix
            ./home-manager-modules/dunst.nix
            ./home-manager-modules/nextcloud.nix
          ];

          role-configuration = {
            inherit user-name;
            git.sign-commits = true;
            suggested-remote-machines = suggested-for-device host-name;
            wallpaper = "${wallpapers}/korangar_synth.png";
          };
        };

        # Steam OS
        jovian.devices.steamdeck.enable = true;
        jovian.steam = {
          enable = true;
          autoStart = true;
          user = user-name;
          desktopSession = "sway";
        };
      };

      #   _____                                    _____ _   _
      #  |  |  |___ ___ ___ ___ ___ ___ ___    ___|  _  | |_| |_ ___ ___ ___
      #  |    -| . |  _| .'|   | . | .'|  _|  |  _|     |  _|   | -_|   | .'|
      #  |__|__|___|_| |__,|_|_|_  |__,|_|    |_| |__|__|_| |_|_|___|_|_|__,|
      #                        |___|
      korangar-rathena = with devices.korangar-rathena; {
        nixpkgs = nixpkgs-korangar-rathena;

        deployment = {
          tags = ["korangar"];
          targetHost = host-name;
        };

        # NixOS modules and config
        imports = [
          ./hardware-configuration/korangar-rathena.nix
          ./nixos-modules/base.nix
          rathena.nixosModules."x86_64-linux".default
        ];

        role-configuration = {
          inherit host-name user-name;
          deployment-key = devices.central.ssh-key;
          authorized-keys = authorized-keys-for-device host-name;
          grub.efi-support = false;
        };

        # home-manager modules and config
        home-manager.users.${user-name} = {
          imports = [
            ./home-manager-modules/base.nix
          ];

          role-configuration = {
            inherit user-name;
            neovim.include-language-servers = false;
          };
        };
      };

      #       ___           ___           ___           ___           ___           ___           ___
      #      /\  \         /\  \         /\__\         /\  \         /\  \         /\  \         /\__\
      #     /::\  \       /::\  \       /::|  |        \:\  \       /::\  \       /::\  \       /:/  /
      #    /:/\:\  \     /:/\:\  \     /:|:|  |         \:\  \     /:/\:\  \     /:/\:\  \     /:/  /
      #   /:/  \:\  \   /::\~\:\  \   /:/|:|  |__       /::\  \   /::\~\:\  \   /::\~\:\  \   /:/  /
      #  /:/__/ \:\__\ /:/\:\ \:\__\ /:/ |:| /\__\     /:/\:\__\ /:/\:\ \:\__\ /:/\:\ \:\__\ /:/__/
      #  \:\  \  \/__/ \:\~\:\ \/__/ \/__|:|/:/  /    /:/  \/__/ \/_|::\/:/  / \/__\:\/:/  / \:\  \
      #   \:\  \        \:\ \:\__\       |:/:/  /    /:/  /         |:|::/  /       \::/  /   \:\  \
      #    \:\  \        \:\ \/__/       |::/  /     \/__/          |:|\/__/        /:/  /     \:\  \
      #     \:\__\        \:\__\         /:/  /                     |:|  |         /:/  /       \:\__\
      #      \/__/         \/__/         \/__/                       \|__|         \/__/         \/__/
      central = with devices.central; {
        deployment = {
          tags = ["home"];
          allowLocalDeployment = true;
        };

        # NixOS modules and config
        imports = [
          ./hardware-configuration/central.nix
          ./nixos-modules/base.nix
          ./nixos-modules/router.nix
          ./nixos-modules/yggdrasil.nix
          ./nixos-modules/docker.nix
          ./nixos-modules/kea.nix
          ./nixos-modules/unbound.nix
          ./nixos-modules/home-assistant.nix
          ./nixos-modules/nextcloud.nix
          ./nixos-modules/immich.nix
          ./nixos-modules/esphome.nix
          rathena.nixosModules."x86_64-linux".default
        ];

        role-configuration = rec {
          inherit host-name user-name;
          authorized-keys = authorized-keys-for-device host-name;
          ip-address = central-ip-address;

          # Network
          subnet = "192.168.188.0/24";
          router-ip = "192.168.188.1";

          # DHCP
          dhcp-pool = "192.168.188.10 - 192.168.188.200";

          yggdrasil = {
            private-key = ./secrets/central-yggdrasil-private-key.age;
            port = yggdrasil-port;
          };

          # Devices with DNS entries and static DHCP rules.
          devices = [
            {
              name = "router";
              ip-address = router-ip;
            }
            {
              name = host-name;
              ip-address = ip-address;
              hw-address = "B0:41:6F:14:D0:E2";
              yggdrasil-address = "200:f5ef:63f7:67dd:36c5:2810:711d:420a";
            }
            {
              name = computer.role-configuration.host-name;
              ip-address = "192.168.188.84";
              hw-address = "C4:03:A8:C9:E7:21";
              yggdrasil-address = "200:e368:5ee6:ed55:4979:2c48:f301:74c";
            }
            {
              name = steam-deck.role-configuration.host-name;
              ip-address = "192.168.188.85";
              hw-address = "14:13:33:D6:65:A1";
              yggdrasil-address = "200:cdf1:2759:d689:fa95:affc:923c:929e";
            }
            {
              name = "controller";
              ip-address = "192.168.188.82";
              hw-address = "94:B9:7E:DA:2D:94";
            }
            {
              name = "computer-case";
              ip-address = "192.168.188.86";
              # hw-address = "94:B9:7E:DA:2D:94";
            }
            {
              name = "doorbell";
              ip-address = "192.168.188.20";
              hw-address = "E8:6B:EA:C3:E3:E8";
            }
            {
              name = "enclosure-lights";
              ip-address = "192.168.188.81";
              hw-address = "94:B9:7E:DA:C2:68";
            }
            {
              name = "kodi";
              ip-address = "192.168.188.12";
              hw-address = "2C:CF:67:01:3E:3D";
            }
            {
              name = korangar-rathena.role-configuration.host-name;
              ip-address = "49.12.109.207";
            }
            {
              name = laptop.role-configuration.host-name;
              ip-address = "192.168.188.102";
              hw-address = "8C:F8:C5:BF:C8:6D";
              yggdrasil-address = "200:35c7:b144:b8c9:b220:f820:1c36:b801";
            }
            {
              name = "lucas-phone";
              ip-address = "192.168.188.128";
              hw-address = "8E:D1:A6:A1:A4:C9";
            }
            {
              name = "octo-print";
              ip-address = "192.168.188.80";
              hw-address = "DC:A6:32:49:D7:03";
            }
            {
              name = "rust-logo";
              ip-address = "192.168.188.83";
              hw-address = "94:B9:7E:DA:8F:64";
            }
            {
              name = "simon-computer";
              ip-address = "192.168.200.1";
            }
            {
              name = "simon-server";
              ip-address = "192.168.200.2";
            }
            {
              name = "tamys-phone";
              ip-address = "192.168.188.101";
              hw-address = "42:95:E6:7C:E0:A5";
            }
            {
              name = "television";
              ip-address = "192.168.188.11";
              hw-address = "A0:62:FB:14:72:E0";
            }
          ];
        };

        # home-manager modules and config
        home-manager.users.${user-name} = {
          imports = [
            ./home-manager-modules/base.nix
            ./home-assistant/controller.nix
            ./home-assistant/computer-case.nix
          ];

          role-configuration = {
            inherit user-name;
            git.sign-commits = true;
          };
        };
      };
    };
  };
}
