# dotfiles

These are my personal dotfiles.

# Install

If you want to try out my configuration on your personal machine, just run this
command:

```sh
$ sh <(curl -L https://shelton.one/install)
```

**NOTE:** While it's simple to test out and roll back a configuration on NixOS,
this is not nearly as easy on macOS. I would not recommend trying out my config
on macOS, but feel free to look around the repository for ideas!

# Nix

My configuration is heavily based on Nix. I use macOS on my laptop with the
[Nix package manager](http://nixos.org), with NixOS on the desktop. Despite
this, I also do lots of deployments to Debian and Fedora machine, so I have
decided not to configure my programs with [home-manager](), instead opting to
use dotfiles directly. There are limited exceptions for programs that
effectively require home-manager for programmatic configuration, because they
don't accept dotfiles.

## Structure

The [nix](./nix) directory is structured around modules that each host can
either include or not, all of which are independent of each other.

The [hosts](./nix/hosts) directory contains Nix files corresponding to the
hostnames of my Nix-enabled machines. Each machine is named after figures in
Roman mythology.

1. Jupiter - My x86\_64 Linux desktop running NixOS. This is my primary
development workstation.

2. Mercury - My M1 Macbook Pro running macOS.

3. Ceres - An arm64 virtual machine hosted on Mercury running NixOS. I use
this VM to test out new Nix configurations and do any Linux-required development
while on the go.

### Testing Linux hosts locally

Every NixOS/Linux configuration also produces an ephemeral QEMU VM. Run Apollo
from the `nix` directory with:

```sh
nix run .#vm.apollo
```

After applying Jupiter's configuration, each guest has a local-only
`<name>.vm.shelton.one` address. TCP ports opened by the guest firewall retain
their port numbers; SSH alone is forwarded through port 2222 and selected
automatically by Jupiter's SSH configuration.

The guest web server is available at `http://apollo.vm.shelton.one:4390`. SSH uses
the same local name and automatically selects its forwarded port, so Apollo is
available with `ssh admin@apollo.vm.shelton.one`. The VM root is backed by memory,
so all guest state disappears when it stops.

While the VM is running, activate local configuration changes without restarting
it with:

```sh
nixos-rebuild test --flake .#apollo-vm \
  --target-host admin@apollo.vm.shelton.one --sudo
```

Using `test` avoids installing a boot entry that cannot survive an ephemeral
VM boot. Stop and rerun `nix run .#vm.apollo` to test boot-time changes.

### Flashing deployment images

Flash a fresh Mars image with its stable SSH host key using either Jupiter or
Mercury:

```sh
cd nix
nix run .#flash.mars -- /dev/sdX
```

The runner builds or reuses the immutable SD image, creates a temporary QCOW2
overlay, injects the encrypted host key after validating it against its tracked
public key, streams the overlay to the selected device, and removes the overlay.
On Mercury, the same injection happens in a transient Linux QEMU appliance.

### Installing Apollo

Apollo is installed remotely with [nixos-anywhere](https://github.com/nix-community/nixos-anywhere),
which wipes its internal disk, partitions it, and installs the flake
configuration along with Apollo's stable SSH host key.

1. In macOS Recovery's Startup Security Utility, set Secure Boot to "No
   Security" and allow booting from external media.
2. Build the installer ISO on Jupiter with `nix build .#images.installer` and
   write it to a USB drive.
3. Connect USB or Thunderbolt Ethernet and a temporary display, then boot the
   USB drive by holding Option at startup.
4. From Jupiter, run:

   ```sh
   nix run .#install.apollo -- root@installer.local
   ```

Afterwards, Apollo needs no display or keyboard. Rebuild it remotely with:

```sh
nixos-rebuild switch --flake .#apollo --target-host admin@apollo --sudo
```

From Mercury, add `--build-host admin@apollo` so Apollo builds its own system.

### VPN

Machines connect to each other over WireGuard, with Apollo as the hub at
`vpn.shelton.one`. Only the VPN subnet is routed through the tunnel, and each
machine is reachable by its bare hostname, e.g. `ssh apollo`. Apollo keeps the
DNS record pointed at the home IP, which requires the router to forward UDP
port 51820 to Apollo.

### DNS

Every record in the `shelton.one` zone is declared in Nix
([modules/server/dns.nix](./nix/modules/server/dns.nix)), and Apollo makes
Cloudflare match on boot and on every rebuild that changes a record. Records
that aren't declared are deleted. Modules declare the names they serve, and
each Cloudflare tunnel hostname gets its record automatically.

| Name | Points at | Reachable |
| --- | --- | --- |
| `shelton.one`, `git.shelton.one` | Apollo's Cloudflare tunnel | publicly, through Cloudflare |
| `cache.shelton.one`, `matrix.shelton.one` | `10.100.0.1` | over the VPN only |
| `vpn.shelton.one` | the home IP, kept current by dyndns | publicly (WireGuard) |

The zone also holds the iCloud Mail records for `@shelton.one` addresses.
Preview a change before deploying it with the commands at the top of
`dns.nix`.

### Binary cache

Apollo serves its Nix store as a binary cache at `http://cache.shelton.one`,
reachable only over the VPN: the name is a DNS-only record pointing at
Apollo's VPN address, `10.100.0.1`.

Every other machine uploads its local builds to Apollo in the background, so a
path built on one machine is available to all of them. Each machine signs its
uploads with its own key, and Apollo accepts only paths signed by those keys.
The cache ranks below cache.nixos.org, so it only supplies what public caches
lack.

### Hardware

The hardware configuration for NixOS machines is auto-generated by the NixOS
installer. To add a new machine, I run the installer and transfer the contents
of `/etc/nixos/hardware-configuration.nix` into a new file under
[hosts](./nix/hosts). As hardware is updated, this host file must be updated to
reflect that new hardware.

### Modules

Whatever machine a software component is used on (Hyprland, for example), I
always want that component to be configured identically. However, I don't want
all modules to be present on all machines. In some examples, not all modules are
even _compatible_ with all machines. My Hyprland configuration doesn't run on
Ceres, for example, because it is a VM, which Hyprland doesn't support.

So I have separated out software components into "modules" which I can
selectively include or exclude on a per-machine basis. These are present in the
[modules](./nix/modules) directory and are imported into the host `.nix` files.

Every module must be fully responsible for itself. If it has a dependency on
another module, then it must import it. This compartmentalizes the modules and
makes them easily swappable.
