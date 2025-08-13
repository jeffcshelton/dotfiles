#!/usr/bin/env sh

# A custom Git shell that automatically creates repositories that do not already
# exist and expands the path to repositories.

case "$SSH_ORIGINAL_COMMAND" in
  'git-upload-pack'* | 'git-receive-pack'* | 'git-upload-archive'*)
    # Recompute the repository path to add "/srv/git" to the front.
    REPO_PATH=$(echo "$SSH_ORIGINAL_COMMAND" \
      | sed -E "s/git-.*'(.+)'/\/srv\/git\/\1/")

    # Create the repository if the command is `git-receive-pack` and the repo
    # directory does not already exist.
    if [ "$(expr "$SSH_ORIGINAL_COMMAND" : 'git-receive-pack')" -ne 0 ] \
       && [ ! -d "$REPO_PATH" ] \
    ; then
      mkdir -p "$REPO_PATH"
      git init --bare "$REPO_PATH"
      echo "Initialized new repository '$REPO_PATH'."
    fi

    # Modify the command to replace the original path with the expanded one.
    COMMAND=$(echo "$SSH_ORIGINAL_COMMAND" | sed -E "s/'(.+)'/'$REPO_PATH'/")
    ;;
  *)
    # Pass through any other commands.
    COMMAND="$SSH_ORIGINAL_COMMAND"
esac

exec git-shell -c "$COMMAND"
