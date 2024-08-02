{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    kicad
    freecad
    openscad
    prusa-slicer
  ];
}
