{
  config,
  lib,
  ...
}: {
  options.role-configuration = with lib; {
    grub = {
      efi-support = mkEnableOption {
        default = true;
      };
      resolution = mkOption {
        type = types.str;
        default = "1920x1080";
      };
    };
  };

  config = with config.role-configuration; {
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
  };
}
