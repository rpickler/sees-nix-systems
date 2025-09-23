{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
let
  secretsDirectory = builtins.toString inputs.nix-secrets;
in
{
  sops = {
    defaultSopsFile = ./secrets.yaml;
    validateSopsFiles = false;
    age = {
      # automatically import host SSH keys as age keys
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };
  };
}
