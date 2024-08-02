{
  pkgs,
  lib,
  ...
}: {
  # TODO: Not working for some reason.
  # services.nextcloud-client = {
  #   enable = true;
  #   startInBackground = true;
  # };

  home.packages = with pkgs; [
    nextcloud-client
  ];

  # FIX: This should be unaware of sway.
  # Start nextcloud when sway starts
  wayland.windowManager.sway.config.startup = [
    {command = "${lib.getExe' pkgs.nextcloud-client "nextcloud"} --background";}
  ];
}
