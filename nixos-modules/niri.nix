{pkgs, ...}: {
  programs.niri.enable = true;

  # XWayland
  environment.systemPackages = [pkgs.xwayland-satellite];

  # Screensharing
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
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
