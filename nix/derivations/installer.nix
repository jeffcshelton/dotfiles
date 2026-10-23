{ pkgs, flake, host, secrets }:
pkgs.writeShellApplication {
  name = "install-${host}";
  runtimeInputs = [ pkgs.coreutils pkgs.nixos-anywhere pkgs.openssh ];
  text = ''
    set -euo pipefail
    umask 077

    if [ "$#" -lt 1 ]; then
      echo "usage: nix run .#install.${host} -- root@<address> [nixos-anywhere options]" >&2
      exit 2
    fi
    target=$1
    shift

    extra=$(mktemp -d)
    trap 'rm -rf "$extra"' EXIT

    # Decrypt the stable host key with this machine's own host key, so every
    # secret encrypted to the target can be decrypted on its first boot. The
    # key is written as this user, not root, so nixos-anywhere can read it.
    mkdir -p "$extra/etc/ssh"
    key=$extra/etc/ssh/ssh_host_ed25519_key
    sudo ${pkgs.age}/bin/age -d -i /etc/ssh/ssh_host_ed25519_key \
      ${secrets}/${host}/system.pem.age | tee "$key" >/dev/null

    derived=$(ssh-keygen -y -f "$key" | cut -d ' ' -f 1-2)
    expected=$(cut -d ' ' -f 1-2 ${secrets}/${host}/system.pub)
    if [ "$derived" != "$expected" ]; then
      echo "error: the decrypted host key does not match ${host}/system.pub" >&2
      exit 1
    fi
    cp ${secrets}/${host}/system.pub "$key.pub"
    chmod 644 "$key.pub"

    # Build locally when this machine can, and on the installer otherwise.
    nixos-anywhere \
      --flake ${flake}#${host} \
      --target-host "$target" \
      --build-on auto \
      --extra-files "$extra" \
      "$@"
  '';
}
