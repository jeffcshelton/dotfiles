{ config, inputs, lib, modulesName, pkgs, ... }:
let
  cfg = config.services.gitea;
  gitea = lib.getExe cfg.package;
  giteaAdmin = "${gitea} --work-path ${cfg.stateDir} --config ${cfg.customDir}/conf/app.ini";
  hostKeys = import ../../secrets/keys;
  managedSshKeys = [
    {
      title = "apollo";
      key = hostKeys.apollo.jeff;
    }
    {
      title = "jupiter";
      key = hostKeys.jupiter.jeff;
    }
    {
      title = "mercury";
      key = hostKeys.mercury.jeff;
    }
  ];
  ensureSshKeys = lib.concatMapStringsSep "\n" ({ title, key }:
    let
      payload = builtins.toJSON {
        inherit key title;
        read_only = false;
      };
    in
    ''
      managed_title=${lib.escapeShellArg title}
      managed_key=${lib.escapeShellArg key}

      if printf '%s' "$existing_keys" \
        | ${lib.getExe pkgs.jq} -e --arg key "$managed_key" \
          'any(.[]; ((.key | split(" ") | .[0:2]) == ($key | split(" ") | .[0:2])))' \
          >/dev/null; then
        echo "Gitea SSH key for $managed_title already exists; leaving it unchanged."
      else
        old_key_id="$(printf '%s' "$existing_keys" \
          | ${lib.getExe pkgs.jq} -r --arg title "$managed_title" \
            'first(.[] | select(.title == $title) | .id) // empty')"
        if [ -n "$old_key_id" ]; then
          ${lib.getExe pkgs.curl} --fail-with-body --silent --show-error \
            --request DELETE \
            --header "Authorization: token $token" \
            "$api_url/admin/users/jeff/keys/$old_key_id"
        fi

        ${lib.getExe pkgs.curl} --fail-with-body --silent --show-error \
          --request POST \
          --header "Authorization: token $token" \
          --header "Content-Type: application/json" \
          --data ${lib.escapeShellArg payload} \
          "$api_url/admin/users/jeff/keys" \
          >/dev/null
        echo "Added the $managed_title SSH key to the Gitea user jeff."
      fi
    '') managedSshKeys;
in
{
  imports = [
    ../wireguard.nix
    inputs.agenix.${modulesName}.default
  ];

  age.secrets.gitea-admin-password = {
    file = ../../secrets/gitea/jeff/password.age;
    owner = cfg.user;
  };

  environment.systemPackages = [ cfg.package ];

  # Gitea's SSH server is reachable only over the VPN.
  networking.firewall.interfaces.wg0.allowedTCPPorts = [
    cfg.settings.server.SSH_LISTEN_PORT
  ];

  services.gitea = {
    enable = true;
    repositoryRoot = "/srv/git";

    settings = {
      server = {
        DOMAIN = "git.shelton.one";
        ROOT_URL = "https://git.shelton.one/";

        # Cloudflared is the only HTTP entry point for the production host.
        HTTP_ADDR = "127.0.0.1";
        HTTP_PORT = 3000;

        # Keep Gitea's SSH endpoint separate from the system SSH service.
        START_SSH_SERVER = true;
        BUILTIN_SSH_SERVER_USER = "git";
        SSH_USER = "git";
        # Clone URLs read git@shelton.one:<owner>/<repo>.git. VPN clients route
        # that to the listener below through SSH config (modules/wireguard.nix).
        SSH_DOMAIN = "shelton.one";
        SSH_PORT = 22;
        SSH_LISTEN_HOST = "0.0.0.0";
        SSH_LISTEN_PORT = 2223;
      };

      service.DISABLE_REGISTRATION = true;
      session.COOKIE_SECURE = true;
    };
  };

  # Create the initial administrator only when it is absent from Gitea's
  # database, with the password from the encrypted secret, then reconcile the
  # explicitly managed client SSH keys. Existing credentials are never
  # reconciled, so rebuilds cannot reset a password changed in Gitea.
  systemd.services.gitea-admin-setup = {
    description = "Create the initial Gitea administrator and SSH keys";
    after = [ "gitea.service" ];
    requires = [ "gitea.service" ];
    wantedBy = [ "multi-user.target" ];

    environment = {
      GITEA_CUSTOM = cfg.customDir;
      GITEA_WORK_DIR = cfg.stateDir;
      HOME = cfg.stateDir;
      USER = cfg.user;
    };

    serviceConfig = {
      Type = "oneshot";
      User = cfg.user;
      Group = cfg.group;
      ExecStart = pkgs.writeShellScript "gitea-admin-setup" ''
        set -euo pipefail

        if ${giteaAdmin} admin user list \
          | ${lib.getExe pkgs.gnugrep} -Eq '^[[:space:]]*[0-9]+[[:space:]]+jeff[[:space:]]'; then
          echo "Gitea administrator jeff already exists; leaving it unchanged."
        else
          # Gitea only accepts the password as an argument, so it is briefly
          # visible to local users; Apollo has no others.
          ${giteaAdmin} admin user create \
            --admin \
            --username jeff \
            --email jeff@shelton.one \
            --password "$(< ${config.age.secrets.gitea-admin-password.path})" \
            --must-change-password=false
        fi

        # Jeff's API tokens are blocked while a password change is pending.
        # Use a short-lived local administrator solely to attach the managed
        # keys without depending on jeff's password state.
        bootstrap_user="nixos-gitea-admin-setup"
        if ${giteaAdmin} admin user list \
          | ${lib.getExe pkgs.gnugrep} -Eq "^[[:space:]]*[0-9]+[[:space:]]+$bootstrap_user[[:space:]]"; then
          ${giteaAdmin} admin user delete --username "$bootstrap_user"
        fi

        bootstrap_password="$(${lib.getExe pkgs.openssl} rand -hex 32)"
        ${giteaAdmin} admin user create \
          --admin \
          --username "$bootstrap_user" \
          --email "$bootstrap_user@gitea.invalid" \
          --password "$bootstrap_password" \
          --must-change-password=false
        bootstrap_password=""

        cleanup_bootstrap() {
          if [ -n "$bootstrap_user" ]; then
            ${giteaAdmin} admin user delete --username "$bootstrap_user"
          fi
        }
        trap cleanup_bootstrap EXIT

        token_name="nixos-gitea-admin-setup-$$"
        token="$(${giteaAdmin} admin user generate-access-token \
          --username "$bootstrap_user" \
          --token-name "$token_name" \
          --scopes write:admin,write:user \
          --raw)"
        api_url="http://127.0.0.1:3000/api/v1"

        existing_keys="$(${lib.getExe pkgs.curl} \
          --fail-with-body --silent --show-error \
          --retry 30 \
          --retry-connrefused \
          --retry-delay 1 \
          --header "Authorization: token $token" \
          "$api_url/users/jeff/keys?limit=50")"

        ${ensureSshKeys}

        cleanup_bootstrap
        bootstrap_user=""
        token=""
        trap - EXIT
      '';
      StandardOutput = "journal+console";
      StandardError = "journal+console";
    };
  };
}
