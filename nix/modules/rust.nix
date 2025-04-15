# Packages and configuration required for Rust development.

{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    cargo-cross
    cargo-tauri
    rustup
  ];
}
