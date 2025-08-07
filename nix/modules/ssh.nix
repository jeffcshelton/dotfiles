{ pkgs, ... }:
{
  programs.ssh.extraConfig = ''
    Host mars.shelton.one
      ProxyCommand ${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h
  '';
}
