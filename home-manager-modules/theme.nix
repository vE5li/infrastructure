{nix-colors, ...}: let
  # https://github.com/przmv/base16-vis
  themes = with nix-colors.colorSchemes; {
    apathy = apathy;
    blueforest = blueforest;
    chalk = chalk;
    cupcake = cupcake;
    darktooth = darktooth;
    estuary = atelier-estuary;
    gigavolt = gigavolt;
    grayscale = grayscale-dark;
    gruvbox = gruvbox-dark-soft;
    hardcore = hardcore;
    hopscotch = hopscotch;
    light = atelier-dune-light;
    mellow-purple = mellow-purple;
    monokai = monokai;
    oceanicnext = oceanicnext;
    outrun = outrun-dark;
    rebecca = rebecca;
    savanna = atelier-savanna;
    tokyo = tokyo-city-dark;
    ashes = ashes;
  };
in {
  # Nix Colors
  imports = [nix-colors.homeManagerModules.default];

  # Selected color scheme
  colorScheme = themes.ashes;
}
