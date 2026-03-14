{ pkgs, unstable, ... }:
{
  environment.systemPackages = with pkgs; [
    starship
    tmux

    # Claude Code and Gemini are dependencies of the Tmux config.
    unstable.codex
    unstable.claude-code
    unstable.gemini-cli

    zoxide
  ];

  programs.zsh.enable = true;
}
