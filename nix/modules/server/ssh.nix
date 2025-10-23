{ isLinux, lib, ... }:
lib.mkMerge [
  {
    services.openssh.enable = true;
  }

  (lib.optionalAttrs isLinux {
    challengeResponseAuthentication = false;
    passwordAuthentication = false;
    usePAM = false;
  })
]
