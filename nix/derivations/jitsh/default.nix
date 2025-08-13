{ pkgs }: pkgs.writeScriptBin "jitsh" (builtins.readFile ./jitsh.sh)
