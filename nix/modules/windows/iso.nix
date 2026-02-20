{
  aria2,
  bash,
  cabextract,
  cacert,
  cdrtools,
  chntpw,
  curl,
  fetchgit,
  jq,
  python3,
  stdenv,
  which,
  wimlib,
  ...
}:

{ uuid, edition ? "professional", lang ? "en-us", sha256 }:

let
  fetchUUPSet = import ./fetchUUPSet.nix {
    inherit aria2 cacert curl jq stdenv;
  };

  uupSet = fetchUUPSet {
    inherit uuid edition lang sha256;
  };
in
stdenv.mkDerivation {
  name = "win11.iso";

  src = fetchgit {
    url = "https://git.uupdump.net/uup-dump/converter.git";
    rev = "dbc65def7a82cd4c4c8b912ac08283d60ecb483b";
    sha256 = "sha256-1B0zxoN4FnQExpzy8mV+/ih70ze1jgtVjCyOZ6Kn4Wc=";
  };

  nativeBuildInputs = [
    bash
    cabextract
    cdrtools
    chntpw
    python3
    which
    wimlib
  ];

  configFile = ''
    VIRTUAL_EDITIONS_LIST='${edition}'
  '';

  passAsFile = [ "configFile" ];

  buildPhase = ''
    cp -r $src/* .
    chmod -R u+w .

    # Patch out the aria2c check, since the script never uses it.
    sed -i 's/aria2c //' convert.sh

    patchShebangs .
    chmod +x convert.sh linux/*.sh
    cp $configFilePath convert_config_linux

    echo "Linking UUP Set..."
    ln -s ${uupSet} uup

    ./convert.sh wim uup/ 0
  '';

  installPhase = ''
    iso=( *.[iI][sS][oO] )

    if [ ! -e "''${iso[0]}" ]; then
      echo "Error: No ISO file was generated."
      exit 1
    fi

    mv "''${iso[0]}" $out
  '';
}
