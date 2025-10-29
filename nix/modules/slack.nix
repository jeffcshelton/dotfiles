{ isDarwin, lib, pkgs, ... }:
lib.optionalAttrs isDarwin {
  environment.systemPackages = with pkgs; [
    slack
  ];
}
