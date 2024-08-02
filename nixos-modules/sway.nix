{pkgs, ...}: {
  # Enable OpenGL
  hardware.graphics.enable = true;

  # NOTE: We enable Sway here *and* in home-manager to set the correct config values for xdg-desktop-portal and opengl.
  programs.sway = {
    enable = true;
    # Disable packages pulled in for the default sway configuration. We will define all packages we need in home-manager.
    extraPackages = [];
  };

  # Screensharing
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    wireplumber.enable = true;
  };

  # Install system fonts
  fonts.packages = with pkgs; [
    jetbrains-mono
    nerd-fonts.symbols-only
    # Japanese
    ipafont
    kochi-substitute
  ];

  # Fonts
  fonts.fontconfig.defaultFonts.monospace = [
    "JetBrains Mono Medium"
  ];
}
