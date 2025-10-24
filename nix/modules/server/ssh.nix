{ isLinux, lib, ... }:
lib.mkMerge [
  {
    services.openssh.enable = true;
  }

  (lib.optionalAttrs isLinux {
    services.openssh.settings.PasswordAuthentication = false;
  })
]
