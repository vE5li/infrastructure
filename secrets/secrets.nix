let
  # Local user ssh key.
  editor = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINxrVu1aTI1If3xBIdCtnOm7z7+KCyWBUfFai9iH9WO5 ve5li@tuta.io";
  # Machine keys.
  computer = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHhaSmp3ZH8eV3AFG/RV9P5LWKm2qZkLSLAGQteGEq75 root@nixos";
  laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILcesFWEgzLsI/xq9RVzhfwz/cqw5nstnn/lBN5q0wPS";
  steam-deck = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAX22zQvXZK8a6mURvH+80Dhp0UWVA8Hv675KDwclBkG";
  gateway = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBLWlLN2wcDyyyTa6PlwWIrtYOrgKnJy55gIg7KKpm+P";
  central = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN7RJZGGnJvyDsLnpie/xAxLbhPX/D+PKAAdGGG47Lef root@nixos";
  vault = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP4ymUjBPn2PBdHWdWfK8zzAd9TlFELsC99WwDRW8OKn";
in {
  "computer-yggdrasil-private-key.age".publicKeys = [editor computer];
  "laptop-yggdrasil-private-key.age".publicKeys = [editor laptop];
  "steam-deck-yggdrasil-private-key.age".publicKeys = [editor steam-deck];
  "gateway-yggdrasil-private-key.age".publicKeys = [editor gateway];
  "central-yggdrasil-private-key.age".publicKeys = [editor central];
  "nextcloud-admin-pass.age".publicKeys = [editor central];
  "esphome-secrets.yaml.age".publicKeys = [editor central];
  "caddy.env.age".publicKeys = [editor central vault];
}
