# Audio configuration that is not specific to hardware.

{ ... }:
{
  # Real-time kit is used by PipeWire for audio processing.
  security.rtkit.enable = true;

  services = {
    pipewire = {
      alsa = {
        enable = true;
        support32Bit = true;
      };

      enable = true;
      jack.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    # Disable PulseAudio in favor of PipeWire.
    pulseaudio.enable = false;
  };
}
