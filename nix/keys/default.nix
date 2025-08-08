{ lib }:
builtins.listToAttrs (map
  (host: {
    name = host;
    value = builtins.listToAttrs (map
      (file: {
        name = lib.removeSuffix ".pub" file;
        value = builtins.readFile ./${host}/${file};
      })
      (builtins.filter (file: lib.hasSuffix ".pub" file)
        (builtins.attrNames (builtins.readDir ./${host}))));
  })
  (builtins.attrNames (builtins.readDir ./.)))
