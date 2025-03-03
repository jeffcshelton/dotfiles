{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    cargo-cross
    cargo-tauri
    rustup
  ];
}
