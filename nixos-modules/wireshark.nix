{pkgs, ...}: {
  # NOTE: Needs to be declared this way for PCAP permissions
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  role-configuration.user.extra-groups = ["wireshark"];
}
