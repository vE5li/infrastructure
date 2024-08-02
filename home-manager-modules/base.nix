{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./theme.nix
    ./neovim.nix
    ./fish.nix
  ];

  options.role-configuration = with lib; {
    user-name = mkOption {
      type = types.nonEmptyStr;
    };
    git = {
      sign-commits = mkEnableOption "signing commits";
    };
  };

  config = with config.role-configuration; {
    # Home Manager itself
    programs.home-manager.enable = true;

    # State version
    home.stateVersion = "25.11";

    # User configuration
    home.username = user-name;
    home.homeDirectory = "/home/${user-name}";

    programs.git = {
      enable = true;
      settings =
        # We need to do a deep merge since `user.signingkey` will overwrite the previous `user.*` values otherwise.
        lib.recursiveUpdate
        {
          user.name = "vE5li";
          user.email = "vE5li@tuta.io";
        }
        (lib.optionalAttrs
          git.sign-commits {
            gpg.format = "ssh";
            commit.gpgsign = true;
            user.signingkey = "~/.ssh/id_ed25519.pub";
          });
    };

    # Git tooling
    home.packages = with pkgs; [
      gh
    ];

    programs.jujutsu = {
      enable = true;
      settings =
        {
          user.name = "vE5li";
          user.email = "vE5li@tuta.io";
          ui.paginate = "never";
          ui.default-command = "log";

          aliases = {
            "e" = ["edit" "--ignore-immutable"];
            "a" = ["abandon"];
            "n" = ["new"];
            "d" = ["describe"];
            "mm" = ["b" "m" "main"];
          };
        }
        // lib.optionalAttrs
        git.sign-commits {
          signing.behavior = "own";
          signing.backend = "ssh";
          signing.key = "~/.ssh/id_ed25519.pub";
        };
    };
  };
}
