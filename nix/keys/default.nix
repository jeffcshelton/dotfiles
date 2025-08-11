let
  # Define custom `removeSuffix` function to avoid requiring lib.
  removeSuffix = suffix: string: (
    builtins.substring
      0
      (builtins.stringLength string - builtins.stringLength suffix)
      string
  );

  # Read the current directory and treat the directories as host listings.
  entries = builtins.readDir ./.;
  hosts = builtins.filter
    (file: entries."${file}" == "directory")
    (builtins.attrNames entries);
in
# Construct an object of the form { "<host>": { "<user": "<key>", ... }, ... }.
# NOTE: The host directories must only contain ".pub" files.
builtins.listToAttrs (map
  (host: {
    name = host;
    value = builtins.listToAttrs (map
      (file: {
        name = removeSuffix ".pub" file;
        value = removeSuffix
          "\n"
          (builtins.readFile ./${host}/${file});
      })
      (builtins.attrNames (builtins.readDir ./${host}))
    );
  })
  hosts
)
