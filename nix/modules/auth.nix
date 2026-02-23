{ unstable, ... }:
{
  programs = {
    _1password = {
      enable = true;
      package = unstable._1password-cli;
    };

    _1password-gui = {
      enable = true;
      package = unstable._1password-gui;
    };
  };
}
