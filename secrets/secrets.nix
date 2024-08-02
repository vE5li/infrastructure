let
  # Local user ssh key.
  editor = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINxrVu1aTI1If3xBIdCtnOm7z7+KCyWBUfFai9iH9WO5 ve5li@tuta.io";
  # Machine keys.
  computer = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHhaSmp3ZH8eV3AFG/RV9P5LWKm2qZkLSLAGQteGEq75 root@nixos";
  laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILcesFWEgzLsI/xq9RVzhfwz/cqw5nstnn/lBN5q0wPS";
  steam-deck = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAX22zQvXZK8a6mURvH+80Dhp0UWVA8Hv675KDwclBkG";
  central = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN7RJZGGnJvyDsLnpie/xAxLbhPX/D+PKAAdGGG47Lef root@nixos";
in {
  "computer-yggdrasil-private-key.age".publicKeys = [editor computer];
  "laptop-yggdrasil-private-key.age".publicKeys = [editor laptop];
  "steam-deck-yggdrasil-private-key.age".publicKeys = [editor steam-deck];
  "central-yggdrasil-private-key.age".publicKeys = [editor central];
  "nextcloud-admin-pass.age".publicKeys = [editor central];
  "esphome-secrets.yaml.age".publicKeys = [editor central];
}
