{...}: {
  # NOTE: Needs to be declared here instead of home manager for OpenGL drivers
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
}
