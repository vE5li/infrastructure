{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    kicad
    freecad
    # Failed to build so I commented it out for now.
    # openscad
    prusa-slicer
  ];
}
