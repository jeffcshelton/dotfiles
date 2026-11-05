{ config, inputs, pkgs, ... }:
{
  imports = [
    # General modules
    ../../modules/agents.nix
    ../../modules/debug.nix
    ../../modules/dev.nix
    ../../modules/locale.nix
    ../../modules/neovim.nix
    ../../modules/net.nix
    ../../modules/nix.nix
    ../../modules/shell.nix
    ../../modules/ssh.nix
    ../../modules/wireguard.nix

    # Server modules
    ../../modules/server/cache.nix
    ../../modules/server/dns.nix
    ../../modules/server/gitea.nix
    ../../modules/server/ssh.nix
    ../../modules/server/tunnel.nix
    ../../modules/server/shelton-one.nix

    # Users
    ../../users/admin.nix
    ../../users/jeff.nix

    # Hardware modules
    inputs.agenix.nixosModules.default
    inputs.persona.nixosModules.default
    inputs.disko.nixosModules.disko
  ];

  boot = {
    initrd.availableKernelModules = [
      "nvme"
      "sd_mod"
      "thunderbolt"
      "usb_storage"
      "usbhid"
      "xhci_pci"
    ];

    kernelModules = [ "kvm-intel" ];

    loader = {
      # Apple's firmware boots the fallback EFI/BOOT/BOOTX64.EFI path, and
      # writing NVRAM boot entries through the T2 is unreliable.
      efi.canTouchEfiVariables = false;

      systemd-boot = {
        configurationLimit = 10;
        enable = true;
      };

      timeout = 1;
    };
  };

  # The whole internal disk is partitioned by nixos-anywhere during installation,
  # and the resulting file systems are mounted from this same layout.
  disko.devices.disk.main = {
    device = "/dev/nvme0n1";
    type = "disk";

    content = {
      type = "gpt";

      partitions = {
        boot = {
          size = "512M";
          type = "EF00";

          content = {
            type = "filesystem";
            format = "vfat";
            extraArgs = [ "-n" "BOOT" ];
            mountpoint = "/boot";
            mountOptions = [ "fmask=0077" "dmask=0077" ];
          };
        };

        root = {
          size = "100%";

          content = {
            type = "filesystem";
            format = "ext4";
            extraArgs = [ "-L" "nixos" ];
            mountpoint = "/";
          };
        };
      };
    };
  };

  hardware = {
    cpu.intel.updateMicrocode = true;
    enableRedistributableFirmware = true;

    # Wi-Fi and Bluetooth firmware is extracted from Apple's macOS recovery
    # image. Only the firmware is taken from the nixos-hardware T2 module: its
    # patched kernel serves the internal keyboard, trackpad, audio, and fans,
    # none of which a headless server needs, and is not binary-cached. The
    # stock kernel already supports the Wi-Fi chip and NVMe drive.
    firmware = [
      (pkgs.callPackage "${inputs.nixos-hardware}/apple/t2/pkgs/brcm-firmware" {
        version = "sonoma";
      })
    ];
  };

  # Apollo is headless, so jeff is a shell account without desktop apps.
  jeff.desktop = false;

  # It's necessary to disable sudo's password requirement for wheel users since
  # the primary user does not have a password.
  #
  # Without this, sudo will still prompt for a password but none will work.
  security = {
    acme = {
      acceptTerms = true;
      certs."matrix.shelton.one" = {
        dnsProvider = "cloudflare";
        credentialFiles.CF_DNS_API_TOKEN_FILE = config.age.secrets.cloudflare-dns-token.path;
      };
      defaults.email = "jeff@shelton.one";
    };

    sudo.wheelNeedsPassword = false;
  };

  # Cloudflare tunnel for public HTTP. The router forwards only WireGuard, so
  # SSH is reachable from the home LAN and over the VPN, never publicly.
  server = {
    cloudflare = {
      enable = true;
      tunnels."06684310-6ec1-40a5-ab96-3f31cfe4d185".ingress = {
        "git.shelton.one" = "http://localhost:3000";
        "shelton.one" = "http://localhost:4390";
      };
    };

    # Apollo owns the shelton.one zone: see modules/server/dns.nix.
    dns = {
      enable = true;

      # Matrix, calls and the personas (services.persona below), reachable
      # over the VPN only.
      records = [
        { name = "matrix.shelton.one"; type = "A"; content = config.vpn.address; }
      ];
    };
  };

  # Initial Matrix passwords. Read one with:
  #   age -d -i ~/.ssh/id_ed25519 secrets/matrix/jeff-password.age
  age.secrets = {
    matrix-jeff-password.file = ../../secrets/matrix/jeff-password.age;
    matrix-caller-password.file = ../../secrets/matrix/caller-password.age;
  };

  services = {
    # A private Matrix server and the personas on it. Sign a persona in to
    # its subscription once with `sudo persona login <name>`.
    persona = {
      enable = true;
      address = "10.100.0.1";
      domain = "matrix.shelton.one";

      # Created on first activation with these passwords; never modified after.
      users = {
        jeff.passwordFile = config.age.secrets.matrix-jeff-password.path;
        caller.passwordFile = config.age.secrets.matrix-caller-password.path;
      };

      owner = "jeff";
      # Each answers calls in its DM, in its own voice (see the voice option).
      # Each also works as its own Linux user in /home/<name>, searches the
      # web through SearXNG, and starts sub-agents on the subscription
      # models it is signed in to (see agentModels).
      personas = {
        # Gemma 4 on Jupiter, for speed; while Jupiter is off, GPT-6 Luna on
        # the ChatGPT plan, through Sign in with ChatGPT.
        sam = {
          model = "jupiter/gemma-4-26b-a4b";
          fallbackModel = "openai/gpt-6-luna";
          voice = "sam"; # a recording in persona's voices/
        };
        # Uses the Claude plan, through Claude Code.
        dario = {
          model = "claude-code/claude-opus-5-5";
          voice = "marius";
        };
      };

      # The local model on Jupiter (modules/local-llm.nix). Gemma 4 reasons
      # unless its chat template is told not to, which Pi does for "off".
      pi.models.jupiter = {
        baseUrl = "http://10.100.0.2:8080/v1";
        api = "openai-completions";
        apiKey = "none";
        models = [{
          id = "gemma-4-26b-a4b";
          reasoning = true;
          contextWindow = 16384;
          maxTokens = 4096;
          compat = {
            thinkingFormat = "chat-template";
            chatTemplateKwargs.enable_thinking."$var" = "thinking.enabled";
            maxTokensField = "max_tokens";
            supportsDeveloperRole = false;
            supportsStore = false;
          };
        }];
      };

      # For openrouter/... models: create the key with
      # `agenix -e openrouter/key.age` (from secrets/), then uncomment.
      # openrouterKeyFile = config.age.secrets.openrouter-key.path;
    };

    # The display has been removed, so the lid sensor must never suspend Apollo.
    logind.settings.Login.HandleLidSwitch = "ignore";

    "shelton.one".port = 4390;
  };

  # The original Nix version installed on Apollo.
  # Do not change this value unless the machine is wiped.
  system.stateVersion = "26.05";

  # Jeff's dotfiles are cloned from the local Gitea on first activation, which
  # only works once Gitea has registered jeff's key.
  systemd.services.home-manager-jeff.after = [ "gitea-admin-setup.service" ];
}
