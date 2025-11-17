{...}: {
  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
    enabledCollectors = [
      "logind"
      "systemd"
      "tcpstat"
    ];
    disabledCollectors = ["textfile"];
    openFirewall = true;
  };
}
