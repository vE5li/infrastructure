{pkgs, ...}: let
  xdg-open-handlr = pkgs.handlr.overrideAttrs (old: {
    postInstall =
      old.postInstall
      + ''
        # Create a script called xdg-open that internally calls handlr
        cp ${pkgs.writeShellScriptBin "xdg-open" "${pkgs.handlr}/bin/handlr open \"$@\""}/bin/xdg-open $out/bin/xdg-open
      '';
  });
in {
  # Add handlr to user packages
  home.packages = [xdg-open-handlr];
}
