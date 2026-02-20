# WinApps / Windows VM integration via KVM + libvirt + NixVirt.
# Linux-only. Surfaces Windows apps natively via FreeRDP RemoteApp.


{ config, inputs, lib, pkgs, ... }:
let
  inherit (inputs) nixvirt winapps;
  cfg = config.windows;

  # pkgs.virtio-win contains raw driver files but no ISO. Build one so libvirt
  # can present it as a CDROM drive during Windows installation.
  virtio-win-iso = pkgs.runCommand "virtio-win.iso"
    { nativeBuildInputs = [ pkgs.cdrkit ]; }
    ''
      genisoimage -o $out -J -r -V virtio-win ${pkgs.virtio-win}
    '';

  # Answer ISO: contains autounattend.xml and the post-install PowerShell
  # script. Windows Setup finds autounattend.xml automatically by scanning
  # all attached drives; no boot order needed.
  answer-iso = import ./autounattend.nix { inherit cfg pkgs; };

  # Windows 11 installation ISO, built from UUP Dump packages.
  win11-iso = (pkgs.callPackage ./iso.nix { }) {
    inherit (cfg.iso) uuid edition lang sha256;
  };

in
{
  imports = [ nixvirt.nixosModules.default ];

  options.windows = {
    iso = {
      uuid = lib.mkOption {
        type = lib.types.str;
        description = "UUP Dump build UUID for the Windows 11 image.";
      };
      edition = lib.mkOption {
        type = lib.types.str;
        default = "professional";
        description = "Windows edition to install (passed to the UUP converter).";
      };
      lang = lib.mkOption {
        type = lib.types.str;
        default = "en-us";
        description = "Language for the Windows installation.";
      };
      sha256 = lib.mkOption {
        type = lib.types.str;
        description = "sha256 hash of the fetched UUP set (for Nix store reproducibility).";
      };
    };

    vcpus = lib.mkOption {
      type = lib.types.int;
      default = 4;
      description = "Number of vCPUs to assign to the Windows VM.";
    };

    memoryMiB = lib.mkOption {
      type = lib.types.int;
      default = 8192;
      description = "RAM (MiB) to assign to the Windows VM.";
    };

    vcpuPinning = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        cpuset string per vCPU index. Empty list disables CPU pinning.
      '';
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "User";
      description = "RDP username for the Windows VM.";
    };

    password = lib.mkOption {
      type = lib.types.str;
      default = "password";
      description = "RDP password for the Windows VM. Set after installing Windows.";
    };
  };

  config = {
    environment = {
      etc."libvirt/hooks/qemu" = {
        mode = "0755";
        text = ''
          #!/run/current-system/sw/bin/bash
          GUEST="$1"
          OP="$2"

          if [[ "$GUEST" == "Windows" ]]; then
            if [[ "$OP" == "prepare" ]]; then
              echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
            elif [[ "$OP" == "release" ]]; then
              echo schedutil | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
            fi
          fi
        '';
      };

      sessionVariables.LIBVIRT_DEFAULT_URI = "qemu:///system";

      systemPackages = with pkgs; [
        freerdp
        winapps.packages.${pkgs.stdenv.system}.winapps
      ];
    };

    programs.virt-manager.enable = true;

    # Create the Windows VM disk image if it does not exist yet.
    # The image has a maximum capacity of 64 GB but expands to fill that.
    system.activationScripts.windows-disk = ''
      if [ ! -f /var/lib/libvirt/images/Windows.qcow2 ]; then
        mkdir -p /var/lib/libvirt/images
        ${pkgs.qemu_kvm}/bin/qemu-img create -f qcow2 \
          /var/lib/libvirt/images/Windows.qcow2 64G
      fi
    '';

    home-manager.users.jeff.home.file.".config/winapps/winapps.conf" = {
      text = ''
        RDP_USER="${cfg.user}"
        RDP_PASS="${cfg.password}"
        WAFLAVOR="libvirt"
        VM_NAME="Windows"
        FREERDP_COMMAND="${pkgs.freerdp}/bin/xfreerdp"
      '';
    };

    virtualisation = {
      libvirt = {
        enable = true;
        swtpm.enable = true;

        connections."qemu:///system" = {
          networks = [{
            definition = nixvirt.lib.network.writeXML {
              name = "default";
              uuid = "9a05da11-e96b-47f3-8253-a3a482e445f5";
              forward = { mode = "nat"; };
              bridge = { name = "virbr0"; stp = true; delay = 0; };
              mac = { address = "52:54:00:a5:b6:c7"; };
              ip = {
                address = "192.168.122.1";
                netmask = "255.255.255.0";
                dhcp.range = { start = "192.168.122.2"; end = "192.168.122.254"; };
              };
            };
            active = true;
          }];

          domains = [{
            definition = nixvirt.lib.domain.writeXML (
              {
                type = "kvm";
                name = "Windows";
                uuid = "a1b2c3d4-e5f6-7890-abcd-ef1234567890";

                memory = { unit = "MiB"; count = cfg.memoryMiB; };
                currentMemory = { unit = "MiB"; count = cfg.memoryMiB; };

                memoryBacking = {
                  hugepages = { };
                  locked = { };
                };

                vcpu = { placement = "static"; count = cfg.vcpus; };

                iothreads = { count = 1; };

                os = {
                  firmware = "efi";
                  # arch and machine are attributes on the <type> child element;
                  # type is its text content.
                  arch = "x86_64";
                  machine = "q35";
                  type = "hvm";
                };

                features = {
                  acpi = { };
                  apic = { };
                  hyperv = {
                    mode = "custom";
                    relaxed = { state = true; };
                    vapic = { state = true; };
                    spinlocks = { state = true; retries = 8191; };
                    vpindex = { state = true; };
                    synic = { state = true; };
                    stimer = { state = true; direct = { state = true; }; };
                    reset = { state = true; };
                    frequencies = { state = true; };
                    reenlightenment = { state = true; };
                    tlbflush = { state = true; };
                    ipi = { state = true; };
                  };
                  kvm.hidden = { state = true; };
                  vmport = { state = false; };
                };

                cpu = {
                  mode = "host-passthrough";
                  check = "none";
                  migratable = false;
                  topology = {
                    sockets = 1;
                    dies = 1;
                    cores = cfg.vcpus;
                    threads = 1;
                  };
                  cache = { mode = "passthrough"; };
                };

                clock = {
                  offset = "localtime";
                  timer = [
                    { name = "rtc"; present = false; }
                    { name = "pit"; present = false; }
                    { name = "hpet"; present = false; }
                    { name = "kvmclock"; present = false; }
                    { name = "hypervclock"; present = true; }
                  ];
                };

                on_poweroff = "destroy";
                on_reboot = "restart";
                on_crash = "destroy";

                pm = {
                  "suspend-to-mem" = { enabled = false; };
                  "suspend-to-disk" = { enabled = false; };
                };

                devices = {
                  disk = [
                    {
                      type = "file";
                      device = "disk";
                      driver = {
                        name = "qemu";
                        type = "qcow2";
                        discard = "unmap";
                        cache = "none";
                        io = "native";
                      };
                      source = { file = "/var/lib/libvirt/images/Windows.qcow2"; };
                      target = { dev = "vda"; bus = "virtio"; };
                      boot = { order = 1; };
                    }
                    {
                      type = "file";
                      device = "cdrom";
                      driver = { name = "qemu"; type = "raw"; };
                      source = { file = "${win11-iso}"; };
                      target = { dev = "sda"; bus = "sata"; };
                      readonly = { };
                      boot = { order = 2; };
                    }
                    {
                      type = "file";
                      device = "cdrom";
                      driver = { name = "qemu"; type = "raw"; };
                      source = { file = "${virtio-win-iso}"; };
                      target = { dev = "sdb"; bus = "sata"; };
                      readonly = { };
                    }
                    {
                      type = "file";
                      device = "cdrom";
                      driver = { name = "qemu"; type = "raw"; };
                      source = { file = "${answer-iso}"; };
                      target = { dev = "sdc"; bus = "sata"; };
                      readonly = { };
                    }
                  ];

                  interface = {
                    type = "network";
                    source = { network = "default"; };
                    model = { type = "virtio"; };
                  };

                  channel = {
                    type = "unix";
                    target = { type = "virtio"; name = "org.qemu.guest_agent.0"; };
                  };

                  graphics = {
                    type = "spice";
                    autoport = true;
                    listen = { type = "address"; address = "127.0.0.1"; };
                    image = { compression = false; };
                  };

                  video = {
                    model = { type = "qxl"; };
                  };

                  memballoon = { model = "virtio"; };

                  rng = {
                    model = "virtio";
                    backend = { model = "random"; source = "/dev/urandom"; };
                  };

                  tpm = {
                    model = "tpm-tis";
                    backend = { type = "emulator"; version = "2.0"; };
                  };
                };
              } // lib.optionalAttrs (cfg.vcpuPinning != [ ]) {
                cputune = {
                  vcpupin = lib.imap0
                    (i: cpuset: { vcpu = i; cpuset = cpuset; })
                    cfg.vcpuPinning;

                  emulatorpin = { cpuset = "0-3"; };
                  iothreadpin = { iothread = 1; cpuset = "0-1"; };
                };
              }
            );
            active = false;
          }];
        };
      };

      libvirtd = {
        onBoot = "ignore";
        qemu.package = pkgs.qemu_kvm;
      };

      spiceUSBRedirection.enable = true;
    };
  };
}
