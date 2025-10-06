{ isDarwin, lib, ... }:
lib.optionalAttrs isDarwin {
  system.defaults.controlcenter = {
    AirDrop = false;
    BatteryShowPercentage = true;
    Bluetooth = true;
    Display = false;
    FocusModes = false;
    NowPlaying = false;
    Sound = true;
  };
}
