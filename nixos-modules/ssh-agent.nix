{
  pkgs,
  config,
  lib,
  ...
}: let
  unlock-ssh-key = pkgs.writeShellScriptBin "unlock-ssh-key" ''
    SSH_AUTH_SOCK=/run/ssh-agent/agent.sock ${lib.getExe' pkgs.openssh "ssh-add"} ${config.role-configuration.ssh-agent.key} < ${config.age.secrets.ssh-key-passphrase.path}
  '';
in {
  options.role-configuration = with lib; {
    ssh-agent = {
      key = mkOption {
        type = types.path;
      };
      passphrase = mkOption {
        type = types.pathInStore;
      };
    };
  };

  config = {
    age.secrets.ssh-key-passphrase.file = config.role-configuration.ssh-agent.passphrase;

    systemd.services.user-ssh-agent = {
      description = "User SSH agent";
      wantedBy = ["default.target"];

      serviceConfig = {
        Type = "simple";
        User = config.role-configuration.user-name;
        ExecStart = "${lib.getExe' pkgs.openssh "ssh-agent"} -D -a /run/ssh-agent/agent.sock";
        RuntimeDirectory = "ssh-agent";
        RuntimeDirectoryPreserve = true;
      };
    };

    systemd.services.unlock-ssh-key = {
      description = "Unlock SSH key";
      wantedBy = ["multi-user.target"];
      after = ["user-ssh-agent.service" "agenix.service"];
      requires = ["user-ssh-agent.service"];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = lib.getExe unlock-ssh-key;
        # The ssh-agent is not immediately ready, so worst case we let it retry a couple of times.
        Restart = "on-failure";
        RestartSec = 1;
      };
    };

    environment.sessionVariables.SSH_AUTH_SOCK = "/run/ssh-agent/agent.sock";
  };
}
