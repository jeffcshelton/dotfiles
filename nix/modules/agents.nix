{ inputs, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    llm-agents.claude-code
    llm-agents.codex
  ];

  nixpkgs.overlays = [ inputs.llm-agents.overlays.shared-nixpkgs ];
}
