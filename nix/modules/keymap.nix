{ isDarwin, lib, ... }:
lib.optionalAttrs isDarwin {
  homebrew.casks = [ "karabiner-elements" ];
}
