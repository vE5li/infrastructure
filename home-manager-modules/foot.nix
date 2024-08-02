{
  pkgs,
  config,
  ...
}: let
  desktopItem = pkgs.makeDesktopItem {
    name = "foot-opener";
    desktopName = "Foot opener";
    exec = "foot -e nvim %f";
    mimeTypes = ["inode/directory"];
  };

  foot-opener = pkgs.stdenv.mkDerivation {
    name = "foot-opener";
    version = "0.0.1";

    # Skip unpack phase, otherwise the package won't build
    unpackPhase = "true";

    # Move `foot-opener.desktop` to the right location
    desktopItems = [desktopItem];
    nativeBuildInputs = [
      pkgs.copyDesktopItems
    ];
    installPhase = ''
      mkdir -p $out/share/applications
      copyDesktopItems
    '';
  };
in {
  home.packages = [
    foot-opener
  ];

  programs.foot = {
    enable = true;

    package = pkgs.foot.overrideAttrs {
      src = pkgs.fetchFromGitHub {
        owner = "ve5li";
        repo = "foot";
        rev = "1d6da1d371beeda1d91651bbf3d9d867b3a1be1c";
        hash = "sha256-BgIWCrjzkhHypU0sa5AOdhw6eFA0W3j8w91TrugGmLY=";
      };
    };

    settings = {
      main = {
        font = "monospace:size=8";
        line-height = 9.8;
        vertical-letter-offset = -0.5;
      };
      scrollback.lines = 5000;
      url.launch = "xdg-open \${url}";
      colors = {
        background = config.colorScheme.palette.base00;
        foreground = config.colorScheme.palette.base05;

        regular0 = config.colorScheme.palette.base00;
        regular1 = config.colorScheme.palette.base08;
        regular2 = config.colorScheme.palette.base0B;
        regular3 = config.colorScheme.palette.base0A;
        regular4 = config.colorScheme.palette.base04;
        regular5 = config.colorScheme.palette.base0E;
        regular6 = config.colorScheme.palette.base0C;
        regular7 = config.colorScheme.palette.base05;

        bright0 = config.colorScheme.palette.base03;
        bright1 = config.colorScheme.palette.base08;
        bright2 = config.colorScheme.palette.base0B;
        bright3 = config.colorScheme.palette.base0A;
        bright4 = config.colorScheme.palette.base0D;
        bright5 = config.colorScheme.palette.base0E;
        bright6 = config.colorScheme.palette.base0C;
        bright7 = config.colorScheme.palette.base07;

        dim0 = config.colorScheme.palette.base01;
        dim1 = config.colorScheme.palette.base08;
        dim2 = config.colorScheme.palette.base0B;
        dim3 = config.colorScheme.palette.base0A;
        dim4 = config.colorScheme.palette.base0D;
        dim5 = config.colorScheme.palette.base0E;
        dim6 = config.colorScheme.palette.base0C;
        dim7 = config.colorScheme.palette.base06;
      };
      key-bindings = {
        show-urls-launch = "Control+u";
      };
    };
  };
}
