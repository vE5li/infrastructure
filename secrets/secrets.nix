let
  # Local user ssh key.
  editor = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPsVnmAVW/35Yk/kiSj5E9nCL88a+te1lO/pJgnpj8L7 lucas@central";
  # Machine keys.
  computer = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHhaSmp3ZH8eV3AFG/RV9P5LWKm2qZkLSLAGQteGEq75 root@nixos";
  laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILcesFWEgzLsI/xq9RVzhfwz/cqw5nstnn/lBN5q0wPS";
  steam-deck = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAX22zQvXZK8a6mURvH+80Dhp0UWVA8Hv675KDwclBkG";
  gateway = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBLWlLN2wcDyyyTa6PlwWIrtYOrgKnJy55gIg7KKpm+P";
  vault = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP4ymUjBPn2PBdHWdWfK8zzAd9TlFELsC99WwDRW8OKn";
  central = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN7RJZGGnJvyDsLnpie/xAxLbhPX/D+PKAAdGGG47Lef root@nixos";
in {
  # Computer
  "computer-yggdrasil-private-key.hjson.age".publicKeys = [editor computer];
  "computer-ssh-key-passphrase.age".publicKeys = [editor computer];

  # Laptop
  "laptop-wireguard-private-key.env.age".publicKeys = [editor laptop];
  "laptop-yggdrasil-private-key.hjson.age".publicKeys = [editor laptop];
  "laptop-ssh-key-passphrase.age".publicKeys = [editor laptop];

  # Steam deck
  "steam-deck-wireguard-private-key.env.age".publicKeys = [editor steam-deck];
  "steam-deck-yggdrasil-private-key.hjson.age".publicKeys = [editor steam-deck];
  "steam-deck-ssh-key-passphrase.age".publicKeys = [editor steam-deck];

  # Gateway
  "gateway-wireguard-private-key.env.age".publicKeys = [editor gateway];
  "gateway-yggdrasil-private-key.hjson.age".publicKeys = [editor gateway];

  # Central
  "central-wireguard-private-key.env.age".publicKeys = [editor central];
  "central-yggdrasil-private-key.hjson.age".publicKeys = [editor central];
  "central-ssh-key-passphrase.age".publicKeys = [editor central];
  "esphome-secrets.yaml.age".publicKeys = [editor central];

  # Caddy
  "caddy.env.age".publicKeys = [editor central vault];
}
