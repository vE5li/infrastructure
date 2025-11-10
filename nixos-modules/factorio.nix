{pkgs, ...}: {
  services.factorio = {
    enable = true;

    # HACK: See: https://github.com/NixOS/nixpkgs/issues/392183
    package = pkgs.factorio-headless.overrideAttrs (old: {
      installPhase =
        old.installPhase
        + ''
          rm -r $out/share/factorio/data/{elevated-rails,quality,space-age}
        '';
    });

    openFirewall = true;
  };
}
