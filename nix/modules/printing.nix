# Printing configuration not specific to hardware.

{ isLinux, lib, pkgs, ... }:
lib.optionalAttrs isLinux {
  environment.systemPackages = with pkgs; [
    simple-scan
  ];

  # Enable document scanning support.
  hardware.sane.enable = true;

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    # Enable printer drivers.
    printing.enable = true;
  };
}
