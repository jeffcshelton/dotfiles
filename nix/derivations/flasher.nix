{ pkgs, image, host, secrets, injectorIso ? null }:
pkgs.writeShellApplication {
  name = "flash-${image.name}";
  runtimeInputs = [ pkgs.age pkgs.coreutils pkgs.openssh pkgs.qemu pkgs.util-linux ]
    ++ pkgs.lib.optionals pkgs.stdenv.isLinux [ pkgs.kmod ];
  text = ''
    set -euo pipefail
    umask 077

    if [ "$#" -ne 1 ]; then
      echo "usage: nix run .#flash.<host> -- /dev/sdX" >&2
      exit 2
    fi
    device=$1
    if [ ! -b "$device" ]; then
      echo "error: $device is not a block device" >&2
      exit 2
    fi
    if [ "$(id -u)" -ne 0 ]; then
      exec sudo -- "$0" "$@"
    fi

    shopt -s nullglob
    images=(${image}/sd-image/*.img)
    if [ "''${#images[@]}" -ne 1 ]; then
      echo "error: expected exactly one SD image in ${image}/sd-image" >&2
      exit 1
    fi
    image="''${images[0]}"
    hostname=${host}

    temporary=$(mktemp -d)
    overlay=$temporary/image.qcow2
    mountdir=$temporary/mount
    attached=0
    mounted=0
    cleanup() {
      status=$?
      trap - EXIT INT TERM
      set +e
      if [ "$mounted" -eq 1 ]; then umount "$mountdir"; fi
      if [ "$attached" -eq 1 ]; then qemu-nbd --disconnect "$nbd"; fi
      rm -rf "$temporary"
      exit "$status"
    }
    trap cleanup EXIT INT TERM

    qemu-img create -f qcow2 -F raw -b "$image" "$overlay" >/dev/null

    ${if pkgs.stdenv.isLinux then ''
      modprobe nbd max_part=16
      for candidate in /dev/nbd*; do
        name=$(basename "$candidate")
        if [ -b "$candidate" ] && [ ! -e "/sys/block/$name/pid" ]; then
          nbd=$candidate
          break
        fi
      done
      : "''${nbd:?error: no free NBD device is available}"
      qemu-nbd --connect "$nbd" "$overlay"
      attached=1
      for _ in $(seq 1 50); do [ -b "''${nbd}p2" ] && break; sleep 0.1; done
      [ -b "''${nbd}p2" ] || { echo "error: SD image root partition was not found" >&2; exit 1; }
      mkdir "$mountdir"
      mount "''${nbd}p2" "$mountdir"
      mounted=1
      case "$hostname" in ""|*[!a-z0-9-]*) echo "error: invalid image hostname" >&2; exit 1;; esac
      secret=${secrets}/$hostname/system.pem.age
      public=${secrets}/$hostname/system.pub
      key=$mountdir/etc/ssh/ssh_host_ed25519_key
      if test -f "$secret" && test -f "$public" && mkdir -p "$mountdir/etc/ssh" && test ! -e "$key" \
        && age -d -i /etc/ssh/ssh_host_ed25519_key -o "$key.inject-ssh" "$secret" 2>/dev/null \
        && chmod 600 "$key.inject-ssh" \
        && ssh-keygen -y -f "$key.inject-ssh" | cut -d ' ' -f 1-2 > "$key.inject-ssh.pub" \
        && cut -d ' ' -f 1-2 "$public" > "$key.inject-ssh.expected" \
        && cmp -s "$key.inject-ssh.pub" "$key.inject-ssh.expected"; then
        mv "$key.inject-ssh" "$key"
        cp "$public" "$key.pub"
        chmod 600 "$key"; chmod 644 "$key.pub"
        echo "Injected SSH host key for $hostname."
      else
        rm -f "$key.inject-ssh" "$key.inject-ssh.pub" "$key.inject-ssh.expected"
        printf '\033[33mwarning: could not decrypt the SSH host key for %s; flashing without it.\033[0m\n' "$hostname" >&2
      fi
      sync
      umount "$mountdir"; mounted=0
      qemu-nbd --disconnect "$nbd"; attached=0
    '' else ''
      status=$temporary/status
      mkdir "$status"
      printf '%s\n' "$hostname" > "$status/hostname"
      qemu-system-x86_64 -nographic -m 768 -cdrom ${injectorIso} \
        -drive file="$overlay",format=qcow2,if=virtio \
        -virtfs local,path=/etc/ssh,mount_tag=identity,security_model=none,readonly=on \
        -virtfs local,path=${secrets},mount_tag=secrets,security_model=none,readonly=on \
        -virtfs local,path="$status",mount_tag=status,security_model=none
      if [ "$(cat "$status/result" 2>/dev/null || true)" = success ]; then
        echo "Injected SSH host key into the image."
      else
        printf '\033[33mwarning: could not decrypt the SSH host key; flashing without it.\033[0m\n' >&2
      fi
    ''}

    echo "Flashing $image with the injected SSH host key to $device..."
    # writethrough reports progress only after each write is flushed, rather
    # than reaching 100% while the host page cache is still draining.
    qemu-img convert -p -t writethrough -O raw "$overlay" "$device"
    sync
  '';
}
