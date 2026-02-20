# Produces an ISO containing autounattend.xml (with @USER@/@PASSWORD@ substituted
# from the windows module options) and postinstall.ps1.  Windows Setup finds
# autounattend.xml automatically by scanning all attached drives.

{ cfg, pkgs }:

let
  xml = builtins.replaceStrings
    [ "@USER@"    "@PASSWORD@"    ]
    [ cfg.user    cfg.password    ]
    (builtins.readFile ./autounattend.xml);

  xmlFile = pkgs.writeText "autounattend.xml" xml;

in pkgs.runCommand "answer.iso"
  { nativeBuildInputs = [ pkgs.cdrkit ]; }
  ''
    mkdir iso
    cp ${xmlFile}            iso/autounattend.xml
    cp ${./postinstall.ps1}  iso/postinstall.ps1
    genisoimage -o $out -J -r -V answer iso/
  ''
