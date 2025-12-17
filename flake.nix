{
  description = "My home infrastructure";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

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

    lan-pam = {
      url = "github:ve5li/lan-pam?dir=pam-exec";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.rust-overlay.follows = "rust-overlay";
    };

    neovim = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
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
      url = "github:ve5li/korangar-rathena";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    jovian-nixos = {
      url = "github:Jovian-Experiments/Jovian-NixOS/bd96a083c5a5b51b67895da5f0523cd695fb87f8";
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

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    colmena,
    agenix,
    home-manager,
    nix-colors,
    lan-pam,
    neovim,
    niri,
    cross-cursor,
    wallpapers,
    rathena,
    jovian-nixos,
    ...
  }: let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      overlays = [niri.overlays.niri];
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
    gateway-ip-address = "167.235.247.100";

    yggdrasil-port = 1660;
    central-yggdrasil-peer = [
      "tcp://${central-ip-address}:${toString yggdrasil-port}"
    ];

    deployment-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPsVnmAVW/35Yk/kiSj5E9nCL88a+te1lO/pJgnpj8L7 lucas@central";

    devices = {
      computer = {
        user-name = "lucas";
        host-name = "computer";
        ssh-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA9oly/zJdXHd2DWBnyLd0+I3kCTFANJwqxMwS4ZbaRZ lucas@computer";
      };
      laptop = {
        user-name = "lucas";
        host-name = "laptop";
        ssh-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDFHaa1wEN2qVKUZjuaoWZun38HhXVR3Z4vRIBfX4ggw lucas@laptop";
      };
      steam-deck = {
        user-name = "lucas";
        host-name = "steam-deck";
        ssh-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOi+cyycCAHeY6k+eZla1k28uBRrlPUUTleuj9ywGmzH lucas@steam-deck";
      };
      korangar-rathena = {
        user-name = "lucas";
        host-name = "korangar-rathena";
      };
      gateway = {
        user-name = "lucas";
        host-name = "gateway";
      };
      vault = {
        user-name = "lucas";
        host-name = "vault";
      };
      central = {
        user-name = "lucas";
        host-name = "central";
      };
      dummy = {
        user-name = "lucas";
        host-name = "dummy";
      };
    };

    device-list = builtins.attrValues devices;

    authorized-keys =
      device-list
      |> builtins.filter (device: builtins.hasAttr "ssh-key" device)
      |> map (device: device.ssh-key);

    suggested-for-device = host-name:
      device-list
      |> builtins.filter (device: device.host-name != host-name)
      |> map (device: "${device.user-name}@${device.host-name}");
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
          niri.nixosModules.niri
        ];

        _module.args = {inherit lan-pam;};

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
          ./nixos-modules/grub.nix
          ./nixos-modules/base.nix
          ./nixos-modules/lan-pam.nix
          ./nixos-modules/ssh-agent.nix
          ./nixos-modules/yggdrasil.nix
          ./nixos-modules/udev-embedded.nix
          ./nixos-modules/audio.nix
          ./nixos-modules/niri.nix
          ./nixos-modules/docker.nix
          ./nixos-modules/wireshark.nix
          ./nixos-modules/android.nix
          ./nixos-modules/steam.nix
          ./nixos-modules/music.nix
          ./nixos-modules/3dprinting.nix
          ./nixos-modules/gaming.nix
          ./nixos-modules/work.nix
          ./nixos-modules/prometheus.nix
        ];

        role-configuration = {
          inherit host-name user-name deployment-key;
          grub.resolution = "3840x1080";

          ssh-agent = {
            key = "/home/${user-name}/.ssh/id_ed25519";
            passphrase = ./secrets/computer-ssh-key-passphrase.age;
          };

          yggdrasil = {
            private-key = ./secrets/computer-yggdrasil-private-key.hjson.age;
            peers = central-yggdrasil-peer;
          };
        };

        # home-manager modules and config
        home-manager.users.${user-name} = {
          imports = [
            ./home-manager-modules/base.nix
            ./home-manager-modules/niri.nix
            ./home-manager-modules/gammastep.nix
            ./home-manager-modules/rofi.nix
            ./home-manager-modules/foot.nix
            ./home-manager-modules/firefox.nix
            ./home-manager-modules/handlr.nix
            ./home-manager-modules/dunst.nix
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
          ./nixos-modules/grub.nix
          ./nixos-modules/base.nix
          ./nixos-modules/lan-pam.nix
          ./nixos-modules/ssh-agent.nix
          ./nixos-modules/yggdrasil.nix
          ./nixos-modules/udev-embedded.nix
          ./nixos-modules/audio.nix
          ./nixos-modules/niri.nix
          ./nixos-modules/docker.nix
          ./nixos-modules/wireshark.nix
          ./nixos-modules/android.nix
          ./nixos-modules/steam.nix
          ./nixos-modules/music.nix
          ./nixos-modules/3dprinting.nix
          ./nixos-modules/gaming.nix
          ./nixos-modules/work.nix
        ];

        role-configuration = {
          inherit host-name user-name deployment-key;

          ssh-agent = {
            key = "/home/${user-name}/.ssh/id_ed25519";
            passphrase = ./secrets/laptop-ssh-key-passphrase.age;
          };

          yggdrasil = {
            private-key = ./secrets/laptop-yggdrasil-private-key.hjson.age;
            peers = central-yggdrasil-peer;
          };
        };

        # home-manager modules and config
        home-manager.users.${user-name} = {
          imports = [
            ./home-manager-modules/base.nix
            ./home-manager-modules/niri.nix
            ./home-manager-modules/gammastep.nix
            ./home-manager-modules/rofi.nix
            ./home-manager-modules/foot.nix
            ./home-manager-modules/firefox.nix
            ./home-manager-modules/handlr.nix
            ./home-manager-modules/dunst.nix
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
          ./nixos-modules/grub.nix
          ./nixos-modules/base.nix
          ./nixos-modules/lan-pam.nix
          ./nixos-modules/ssh-agent.nix
          ./nixos-modules/yggdrasil.nix
          ./nixos-modules/audio.nix
          ./nixos-modules/niri.nix
          ./nixos-modules/docker.nix
          ./nixos-modules/wireshark.nix
          ./nixos-modules/music.nix
          ./nixos-modules/gaming.nix
          jovian-nixos.nixosModules.default
        ];

        role-configuration = {
          inherit host-name user-name deployment-key;

          ssh-agent = {
            key = "/home/${user-name}/.ssh/id_ed25519";
            passphrase = ./secrets/steam-deck-ssh-key-passphrase.age;
          };

          yggdrasil = {
            private-key = ./secrets/steam-deck-yggdrasil-private-key.hjson.age;
            peers = central-yggdrasil-peer;
          };
        };

        # home-manager modules and config
        home-manager.users.${user-name} = {
          imports = [
            ./home-manager-modules/base.nix
            ./home-manager-modules/niri.nix
            ./home-manager-modules/gammastep.nix
            ./home-manager-modules/rofi.nix
            ./home-manager-modules/foot.nix
            ./home-manager-modules/firefox.nix
            ./home-manager-modules/handlr.nix
            ./home-manager-modules/dunst.nix
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
          desktopSession = "niri";
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
          ./nixos-modules/grub.nix
          ./nixos-modules/base.nix
          rathena.nixosModules."x86_64-linux".default
        ];

        role-configuration = {
          inherit host-name user-name deployment-key authorized-keys;
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

      #  __________  _______   _________  __________ _________  _______ ____   ____
      # /   /_____/ /   O   \ /__     __\/   /_____//   \ /   \/   O   \\___\_/___/
      # \___\%%%%.]/___/%\___\`%%|___|%%'\___\%%%%%'\____|____/___/%\___\%%%/_\%%%
      #  `BBBBBBBB'`BB'   `BB'    `B'     `BBBBBBBB' `BBBBBBB'`BB'   `BB'   `B'
      #
      gateway = with devices.gateway; {
        deployment = {
          tags = ["home"];
          targetHost = host-name;
        };

        # NixOS modules and config
        imports = [
          ./hardware-configuration/gateway.nix
          ./nixos-modules/grub.nix
          ./nixos-modules/base.nix
          ./nixos-modules/yggdrasil.nix
        ];

        role-configuration = {
          inherit host-name user-name deployment-key authorized-keys;
          grub.efi-support = false;

          yggdrasil = {
            private-key = ./secrets/gateway-yggdrasil-private-key.hjson.age;
            public-keys = [
              # Central
              "85084e044c11649d6bf7c7715efa80f274b2ec3298cb868756e21d0b0a2b0559"
              # Simon PC
              "b12d3901b159029248c28244dbb40b5965f7a6106464f362adf48970a400a970"
              # Jonas PC
              "0d07dc9e44f04f4da3ac2f3bb17948b4259a8f7df51ab9ffeca225eb41ac9fab"
              # Jannik PC
              "5aa43460e274dccaa5917a901ed991cd3f792e6e301a34749a18b59ec1e2e09c"
              # Daniel PC
              "e598c07f2561e874d2867e073ddebb128019176d6a7c2a8488e8df95b5e335b2"
            ];
            port = yggdrasil-port;
          };
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

      #     _      _          _      _          _
      #  _ /\\  __/\\__  ___ /\\   _/\\_     __/\\__
      # / \\ \\(_  ____)/  //\ \\ (_  _))   (__  __))
      # \:'/ // /  _ \\ \:.\\_\ \\ /  \\      /  \\
      #  \  // /:./_\ \\ \  :.  ///:.  \\__  /:.  \\
      # (_  _))\  _   //(_   ___))\__  ____))\__  //
      #   \//   \// \//   \//        \//        \//
      #
      vault = with devices.vault; {
        deployment = {
          tags = ["home"];
          targetHost = host-name;
        };

        # NixOS modules and config
        imports = [
          ./hardware-configuration/vault.nix
          ./nixos-modules/grub.nix
          ./nixos-modules/base.nix
          ./nixos-modules/lan-pam.nix
          ./nixos-modules/caddy.nix
          ./nixos-modules/prometheus.nix
        ];

        role-configuration = {
          inherit host-name user-name deployment-key;

          domain = "0x0c.dev";
        };

        # home-manager modules and config
        home-manager.users.${user-name} = {
          imports = [
            ./home-manager-modules/base.nix
          ];

          role-configuration = {
            inherit user-name;
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
          ./nixos-modules/grub.nix
          ./nixos-modules/base.nix
          ./nixos-modules/lan-pam.nix
          ./nixos-modules/ssh-agent.nix
          ./nixos-modules/router.nix
          ./nixos-modules/yggdrasil.nix
          ./nixos-modules/unifi.nix
          ./nixos-modules/docker.nix
          ./nixos-modules/kea.nix
          ./nixos-modules/unbound.nix
          ./nixos-modules/caddy.nix
          ./nixos-modules/home-assistant.nix
          ./nixos-modules/prometheus.nix
          ./nixos-modules/grafana.nix
          ./nixos-modules/esphome.nix
          ./nixos-modules/factorio.nix
          ./nixos-modules/minecraft.nix
          rathena.nixosModules."x86_64-linux".default
        ];

        role-configuration = rec {
          inherit host-name user-name;
          ip-address = central-ip-address;

          # Network
          domain = "0x0c.dev";
          subnet = "192.168.188.0/24";
          router-ip = "192.168.188.1";

          # DHCP
          dhcp-pool = "192.168.188.10 - 192.168.188.200";

          ssh-agent = {
            key = "/home/${user-name}/.ssh/id_ed25519";
            passphrase = ./secrets/central-ssh-key-passphrase.age;
          };

          yggdrasil = {
            private-key = ./secrets/central-yggdrasil-private-key.hjson.age;
            peers = ["tcp://${gateway-ip-address}:${toString yggdrasil-port}"];
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
              subdomains = ["home-assistant" "grafana" "unifi"];
            }
            {
              name = vault.role-configuration.host-name;
              ip-address = "192.168.188.22";
              hw-address = "9C:6B:00:AD:80:1C";
            }
            {
              name = gateway.role-configuration.host-name;
              ip-address = gateway-ip-address;
              yggdrasil-address = "201:19bb:f374:e243:664c:fa11:a325:4256";
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
              name = "phone";
              ip-address = "192.168.188.12";
              hw-address = "78:53:64:06:26:DC";
              yggdrasil-address = "201:9283:384b:e6a8:c56c:be94:db6a:fff2";
            }
            {
              name = "controller";
              ip-address = "192.168.188.82";
              hw-address = "94:B9:7E:DA:2D:94";
            }
            {
              name = "computer-case";
              ip-address = "192.168.188.86";
              hw-address = "C0:CD:D6:CA:58:28";
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
              name = "computer-lights";
              ip-address = "192.168.188.89";
              hw-address = "E8:6B:EA:C4:65:80";
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
              yggdrasil-address = "200:9da5:8dfc:9d4d:fadb:6e7a:fb76:4897";
            }
            {
              name = "television";
              ip-address = "192.168.188.11";
              hw-address = "A0:62:FB:14:72:E0";
            }
            {
              name = dummy.role-configuration.host-name;
              ip-address = "192.168.188.99";
              hw-address = "9C:6B:00:A7:E6:FF";
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

      #    ___                             _  _
      #   |   \   _  _    _ __    _ __    | || |
      #   | |) | | +| |  | '  \  | '  \    \_, |
      #   |___/   \_,_|  |_|_|_| |_|_|_|  _|__/
      # _|"""""|_|"""""|_|"""""|_|"""""|_| """"|
      # "`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'
      #
      dummy = with devices.dummy; {
        deployment = {
          tags = ["home"];
          targetHost = host-name;
        };

        # NixOS modules and config
        imports = [
          ./hardware-configuration/dummy.nix
          ./nixos-modules/grub.nix
          ./nixos-modules/base.nix
          ./nixos-modules/lan-pam.nix
        ];

        role-configuration = {
          inherit host-name user-name deployment-key;
        };

        # home-manager modules and config
        home-manager.users.${user-name} = {
          imports = [
            ./home-manager-modules/base.nix
          ];

          role-configuration = {
            inherit user-name;
          };
        };
      };
    };
  };
}
