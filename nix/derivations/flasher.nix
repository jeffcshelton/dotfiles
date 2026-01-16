{ pkgs, image }:
let
  # Darwin hosts do not support bmaptool, so they must use dd instead.
  darwinFlash = ''
    ${pkgs.coreutils}/bin/dd if="${image}" of="$DEVICE" status=progress conv=fsync
  '';

  linuxFlash = ''
    ${pkgs.bmaptool}/bin/bmaptool copy --nobmap "${image}" "$DEVICE"
  '';
in
pkgs.writeShellScriptBin "${image.name}-flasher" ''
  #!${pkgs.bash}/bin/bash
  set -e

  DEVICE="$1"

  # Check that a device was specified.
  if [ -z "$DEVICE" ]; then
    echo "error: no device path specified" >&2
    echo "usage: nix run .#flash.<host> -- /dev/sdX" >&2
    exit 1
  fi

  echo "Flashing ${image} to $DEVICE..."
  ${if pkgs.stdenv.isDarwin then darwinFlash else linuxFlash}
''
