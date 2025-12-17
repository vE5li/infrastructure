{
  pkgs,
  lib,
  config,
  ...
}: {
  options.role-configuration = with lib; {
    user-name = mkOption {
      type = types.str;
    };
    user = {
      extra-groups = mkOption {
        type = types.listOf types.str;
        default = [];
      };
    };
    grub = {
      efi-support = mkEnableOption {
        default = true;
      };
      resolution = mkOption {
        type = types.str;
        default = "1920x1080";
      };
    };
    host-name = mkOption {
      type = types.str;
    };
    deployment-key = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    authorized-keys = mkOption {
      type = types.listOf types.str;
      default = [];
    };
  };

  config = with config.role-configuration; {
    system.stateVersion = "26.05";

    nix.settings.experimental-features = [
      "flakes"
      "nix-command"
      "pipe-operators"
    ];

    # Optimize store.
    nix.optimise.automatic = true;

    # Allow non-FOSS packages.
    nixpkgs.config.allowUnfree = true;

    boot.loader = {
      efi.canTouchEfiVariables = grub.efi-support;
      grub = {
        enable = true;
        devices = ["nodev"];
        efiSupport = grub.efi-support;
        gfxmodeBios = grub.resolution;
      };
      # Give the user some extra time to select a boot option
      timeout = 10;
    };

    environment.systemPackages = with pkgs; [
      nix-index
      nix-tree
      neovim
      killall
      wget
      zip
      unzip
      dig
    ];

    # Limit the amount of logs to keep.
    services.journald.extraConfig = "SystemMaxUse=100M";

    # Time zone.
    time.timeZone = "Europe/Berlin";

    # Internationalisation.
    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "de_DE.UTF-8";
      LC_IDENTIFICATION = "de_DE.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_NAME = "de_DE.UTF-8";
      LC_NUMERIC = "de_DE.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "de_DE.UTF-8";
    };

    # Keyboard layout.
    console.keyMap = "de";

    # Fish shell
    programs.fish.enable = true;

    # Define user accounts
    users.users.${user-name} = {
      isNormalUser = true;
      description = user-name;
      extraGroups = ["wheel"] ++ user.extra-groups;
      openssh.authorizedKeys.keys = authorized-keys;
      shell = pkgs.fish;
    };

    # Fallback editor
    environment.variables.EDITOR = "nvim";

    # SSH
    services.openssh.enable = true;
    programs.ssh.extraConfig = ''
      ServerAliveInterval 60
      ServerAliveCountMax 120
    '';

    # Enable keyring for nextcloud-client.
    services.gnome.gnome-keyring.enable = true;

    # Root authorizedKeys so that colmena can deploy to the machine.
    users.users.root.openssh.authorizedKeys.keys = lib.optional (deployment-key != null) deployment-key;

    # Networking
    networking.hostName = config.role-configuration.host-name;

    networking.networkmanager.enable = true;
    role-configuration.user.extra-groups = ["networkmanager"];

    networking.wireguard.enable = true;
  };
}
