# Printing configuration not specific to hardware.

{ isLinux, lib, pkgs, ... }:
lib.optionalAttrs isLinux {
  environment.systemPackages = with pkgs; [
    simple-scan
  ];

  # Enable document scanning support.
  hardware.sane.enable = true;

  # Enable printer drivers.
  services.printing.enable = true;
}
