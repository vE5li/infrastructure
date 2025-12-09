{...}: {
  # TODO: Currently the minecraft server is started through docker but I would like to move it here.

  networking.firewall = {
    allowedTCPPorts = [25565];
  };
}
