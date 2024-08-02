{
  pkgs,
  config,
  ...
}: {
  age.secrets.nextcloud-admin-pass.file = ../secrets/nextcloud-admin-pass.age;

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud32;
    hostName = with config.role-configuration; "nextcloud.${host-name}.${domain}";

    # Install and configure the database automatically.
    database.createLocally = true;

    # Install and configure Redis caching automatically.
    configureRedis = true;

    # Increase the maximum file upload size to avoid problems uploading videos.
    maxUploadSize = "16G";

    # Automatically update installed apps.
    autoUpdateApps.enable = true;

    # Nextcloud config.
    config = {
      dbtype = "sqlite";
      adminpassFile = config.age.secrets.nextcloud-admin-pass.path;
    };
  };

  networking.firewall = {
    allowedTCPPorts = [
      80
      443
    ];
  };

  role-configuration.subdomains = ["nextcloud"];
}
