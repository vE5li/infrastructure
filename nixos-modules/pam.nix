{
  pkgs,
  config,
  lib,
  lan-pam,
  ...
}: let
  configuration = {
    source_name = config.role-configuration.host-name;
    devices = [
      {
        name = "Phone (local)";
        ip_address = "192.168.188.12:4200";
        public_key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1SN9GdLat9NI7yhczu8DgGX0VbewMvDXWNo6+CnTCpyITXmYCzv/0GkuuCXrG3C876R9HC3f2j6PfWEsc1NWTgQyI01OqATVw5PD0eEwaH3vAmdaHXSJurXJDbg9B2XQ+L2IkPf1uWlMyxrOGlMtRSt8Zn+Tm1eitrc8K4pQp+xCYPe26vie3Rvq11l9mIHWrj7y4mdGL0ILQQ3LkQunOxgtARRIs5ZXmskAeQQIiyT5d9MTVhz6EglB7bwnVTg+Ku3o02LVC27YNNHfFtqC1TAc2y4VV9pRPuVRCHZkKQvUaHbVyQbkR0TAjd/RtC8ys/KV/zynAsNipn/gStxAMQIDAQAB";
      }
    ];
  };

  configuration-file = pkgs.writeText "config.json" (lib.strings.toJSON configuration);
in {
  security.pam.services.login.rules.auth.lan-pam = {
    enable = true;
    control = "sufficient";
    order = config.security.pam.services.login.rules.auth.unix-early.order - 1;
    modulePath = "${config.security.pam.package}/lib/security/pam_exec.so";
    args = [
      "debug"
      "quiet"
      "log=/var/run/lan-pam.log"
      "${lib.getExe lan-pam.packages.${pkgs.stdenv.hostPlatform.system}.default}"
      "${configuration-file}"
    ];
  };

  # For the root account: Validate all account requests using LAN-PAM.
  #
  # As a result deploying using colmena also requires this, regardless of the authorized keys.
  security.pam.services.sshd.rules.account.lan-pam-root = {
    enable = true;
    control = "[success=1 default=ignore]";
    order = config.security.pam.services.sshd.rules.account.lan-pam.order - 1;
    modulePath = "${config.security.pam.package}/lib/security/pam_succeed_if.so";
    args = ["user" "!=" "root"];
  };
  security.pam.services.sshd.rules.account.lan-pam = {
    enable = true;
    control = "[success=done default=bad]";
    order = config.security.pam.services.sshd.rules.account.unix.order - 1;
    modulePath = "${config.security.pam.package}/lib/security/pam_exec.so";
    args = [
      "debug"
      "quiet"
      "log=/var/run/lan-pam.log"
      "${lib.getExe lan-pam.packages.${pkgs.stdenv.hostPlatform.system}.default}"
      "${configuration-file}"
    ];
  };

  # For the user accounts: Validate all auth requests using LAN-PAM.
  #
  # Root requests are skipped so logging in as root doesn't require two LAN-PAM requests.
  security.pam.services.sshd.rules.auth.lan-pam-user = {
    enable = true;
    control = "[success=1 default=ignore]";
    order = config.security.pam.services.sshd.rules.auth.lan-pam.order - 1;
    modulePath = "${config.security.pam.package}/lib/security/pam_succeed_if.so";
    args = ["user" "=" "root"];
  };
  security.pam.services.sshd.rules.auth.lan-pam = {
    enable = true;
    control = "sufficient";
    order = config.security.pam.services.sshd.rules.auth.unix.order - 1;
    modulePath = "${config.security.pam.package}/lib/security/pam_exec.so";
    args = [
      "debug"
      "quiet"
      "log=/var/run/lan-pam.log"
      "${lib.getExe lan-pam.packages.${pkgs.stdenv.hostPlatform.system}.default}"
      "${configuration-file}"
    ];
  };

  security.pam.services.sudo.rules.auth.lan-pam = {
    enable = true;
    control = "sufficient";
    order = config.security.pam.services.sudo.rules.auth.unix.order - 1;
    modulePath = "${config.security.pam.package}/lib/security/pam_exec.so";
    args = [
      "debug"
      "quiet"
      "log=/var/run/lan-pam.log"
      "${lib.getExe lan-pam.packages.${pkgs.stdenv.hostPlatform.system}.default}"
      "${configuration-file}"
    ];
  };
}
