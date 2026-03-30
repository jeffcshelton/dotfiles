{ pkgs, ... }:
{
  environment.systemPackages = with pkgs.python3Packages; [
    pkgs.python3

    matplotlib
    numpy
    pandas
    requests
    scikit-learn
  ];
}
