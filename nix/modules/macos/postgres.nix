{ ... }:
{
  # For an unknown reason, the "postgresql" system package does not seem to work
  # on macOS. It fails to start due to not finding shared libraries.
  #
  # So instead, I use Homebrew to configure it. This also allows me to control
  # Postgres through Homebrew services, which is the familiar method on macOS.
  homebrew.brews = [
    {
      name = "libpq";
      link = true;
    }
    "postgresql@17"
  ];
}
