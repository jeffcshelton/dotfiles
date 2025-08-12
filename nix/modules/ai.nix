{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    codex
    ollama
  ];
}
