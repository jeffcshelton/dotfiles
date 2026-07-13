{ config, lib, modulesPath, pkgs, ... }:
{
  imports = [ "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix" ];

  boot.kernelParams = [ "console=ttyS0" ];
  documentation.enable = false;
  services.getty.autologinUser = lib.mkForce "root";

  environment.systemPackages = [ pkgs.age pkgs.openssh pkgs.coreutils ];

  fileSystems = {
    "/mnt/identity" = {
      device = "identity";
      fsType = "9p";
      options = [ "trans=virtio" "version=9p2000.L" "ro" ];
    };
    "/mnt/secrets" = {
      device = "secrets";
      fsType = "9p";
      options = [ "trans=virtio" "version=9p2000.L" "ro" ];
    };
    "/mnt/status" = {
      device = "status";
      fsType = "9p";
      options = [ "trans=virtio" "version=9p2000.L" ];
    };
  };

  systemd.services.inject-ssh-host-key = {
    description = "Inject encrypted SSH host key into the attached SD image";
    wantedBy = [ "multi-user.target" ];
    after = [ "mnt-identity.mount" "mnt-secrets.mount" "mnt-status.mount" ];
    serviceConfig.Type = "oneshot";
    script = ''
      set -euo pipefail
      umask 077
      temporary=
      derived=
      expected=
      trap 'rm -f "$temporary" "$derived" "$expected"; echo unavailable > /mnt/status/result; poweroff -f' EXIT

      mkdir -p /mnt/image
      mount /dev/vda2 /mnt/image
      hostname=$(tr -d '\r\n' < /mnt/image/etc/hostname)
      case "$hostname" in
        ""|*[!a-z0-9-]*) exit 1 ;;
      esac

      secret=/mnt/secrets/$hostname/system.pem.age
      public=/mnt/secrets/$hostname/system.pub
      key=/mnt/image/etc/ssh/ssh_host_ed25519_key
      temporary=$key.inject-ssh
      derived=$temporary.pub
      expected=$temporary.expected

      if test -f "$secret" && test -f "$public" && test ! -e "$key" \
        && age -d -i /mnt/identity/ssh_host_ed25519_key -o "$temporary" "$secret" 2>/dev/null \
        && chmod 600 "$temporary" \
        && ssh-keygen -y -f "$temporary" | cut -d ' ' -f 1-2 > "$derived" \
        && cut -d ' ' -f 1-2 "$public" > "$expected" \
        && cmp -s "$derived" "$expected"; then
        mv "$temporary" "$key"
        cp "$public" "$key.pub"
        chmod 600 "$key"
        chmod 644 "$key.pub"
        result=success
      else
        rm -f "$temporary" "$derived" "$expected"
        result=unavailable
      fi
      sync
      umount /mnt/image
      echo "$result" > /mnt/status/result
      trap - EXIT
      poweroff -f
    '';
  };
}
