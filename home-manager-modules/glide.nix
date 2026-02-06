{
  pkgs,
  glide,
  ...
}: {
  home.packages = [
    (glide.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
      extraPolicies = {
        AutofillAddressEnabled = true;
        AutofillCreditCardEnabled = false;
      };

      # TODO:
      # - layout.css.devPixelsPerPx to ~0.8
      # - browser.sessionstore.restore_tabs_lazily to false
      # - browser.startup.page to 3
      # - Set dark theme
    })
  ];
}
