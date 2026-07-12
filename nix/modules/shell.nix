{ inputs, pkgs, unstable, ... }:
{
  environment.systemPackages = with pkgs; [
    starship
    tmux

    inputs.codex.packages.${pkgs.stdenv.hostPlatform.system}.default
    unstable.claude-code
    unstable.gemini-cli

    zoxide
  ];

  programs.zsh.enable = true;
}
