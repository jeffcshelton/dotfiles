# Share builds through Apollo's binary cache over the VPN, served by
# modules/server/cache.nix.
#
# Every local build is queued by a post-build hook and uploaded to Apollo in
# the background, and every machine substitutes from Apollo, so a path built on
# one machine is available to all of them.

{ config, host, inputs, isDarwin, isLinux, lib, modulesName, pkgs, ... }:
let
  domain = "cache.shelton.one";
  state = "/nix/var/nix-upload";

  # Runs inside the Nix daemon after each local build. The daemon stops if
  # this fails, so it only records the paths and never touches the network.
  queueBuild = pkgs.writeShellScript "nix-upload-queue" ''
    [ -n "''${OUT_PATHS:-}" ] || exit 0
    mkdir -p ${state}
    ${pkgs.flock}/bin/flock ${state}/lock \
      sh -c 'printf "%s\n" $OUT_PATHS >> ${state}/queue' || true
  '';

  upload = pkgs.writeShellApplication {
    name = "nix-upload";
    runtimeInputs = [ config.nix.package pkgs.coreutils pkgs.flock pkgs.openssh ];
    text = ''
      mkdir -p ${state}
      cd ${state}

      # Claim newly queued paths, keeping any that failed to upload before.
      flock lock sh -c 'if [ -e queue ]; then cat queue >> pending && rm queue; fi'
      [ -s pending ] || exit 0

      # Skip duplicates and paths collected since they were built.
      paths=()
      while read -r path; do
        if [ -e "$path" ]; then paths+=("$path"); fi
      done < <(sort -u pending)

      if [ "''${#paths[@]}" -gt 0 ]; then
        # Sign the whole closure so Apollo accepts dependencies built before
        # this machine had a key. Apollo fetches anything public itself.
        nix store sign --recursive \
          --key-file ${config.age.secrets.cache-signing-key.path} "''${paths[@]}"

        NIX_SSHOPTS="-o BatchMode=yes -o ConnectTimeout=10" nix copy \
          --substitute-on-destination \
          --to "ssh-ng://nix-upload@apollo?ssh-key=/etc/ssh/ssh_host_ed25519_key" \
          "''${paths[@]}"
      fi

      rm pending
    '';
  };
in
{
  imports = [
    ./nix.nix
    ./ssh.nix
    ./wireguard.nix
    inputs.agenix.${modulesName}.default
  ];

  config = lib.mkMerge [
    {
      age.secrets.cache-signing-key.file = ../secrets/cache/${host}.key.age;

      nix.settings = {
        # The cache's own priority keeps cache.nixos.org preferred for
        # anything both can serve.
        extra-substituters = [ "http://${domain}" ];

        extra-trusted-public-keys = [
          (lib.removeSuffix "\n" (builtins.readFile ../secrets/cache/apollo.pub))
        ];

        # Fail fast when the VPN is down rather than stalling every build on
        # the unreachable cache.
        connect-timeout = 5;

        post-build-hook = queueBuild;
      };
    }

    (lib.optionalAttrs isLinux {
      # Public DNS points the domain at Apollo's VPN address too, but pinning
      # it avoids resolvers that refuse public names resolving to private
      # addresses.
      networking.hosts."10.100.0.1" = [ domain ];

      # Upload whenever the queue changes, and retry periodically in case the
      # VPN was down.
      systemd.paths.nix-upload = {
        wantedBy = [ "paths.target" ];
        pathConfig.PathModified = "${state}/queue";
      };

      systemd.services.nix-upload = {
        description = "Upload local Nix builds to Apollo's binary cache";
        startAt = "*:0/15";

        # Builds can modify the queue many times in quick succession.
        unitConfig.StartLimitIntervalSec = 0;

        serviceConfig = {
          Type = "oneshot";
          ExecStart = lib.getExe upload;
        };
      };
    })

    (lib.optionalAttrs isDarwin {
      launchd.daemons.nix-upload.serviceConfig = {
        ProgramArguments = [ (lib.getExe upload) ];
        WatchPaths = [ "${state}/queue" ];
        StartInterval = 900;
        StandardErrorPath = "/var/log/nix-upload.log";
        StandardOutPath = "/var/log/nix-upload.log";
      };
    })
  ];
}
