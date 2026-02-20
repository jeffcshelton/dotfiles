#Requires -RunAsAdministrator
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Log($msg) { Write-Output "[$(Get-Date -Format 'HH:mm:ss')] $msg" }

# ── 1. virtio drivers ─────────────────────────────────────────────────────────

Log "Locating virtio-win disc..."
$virtio = Get-Volume |
    Where-Object { $_.FileSystemLabel -like 'virtio-win*' } |
    Select-Object -First 1 -ExpandProperty DriveLetter

if (-not $virtio) {
    Log "WARNING: virtio-win disc not found; skipping driver and guest-agent steps."
} else {
    Log "virtio-win found at ${virtio}:\"

    Log "Installing NetKVM (virtio network)..."
    pnputil /add-driver "${virtio}:\NetKVM\w11\amd64\netkvm.inf" /install

    Log "Installing balloon driver..."
    pnputil /add-driver "${virtio}:\Balloon\w11\amd64\balloon.inf" /install

    $gaMsi = "${virtio}:\guest-agent\qemu-ga-x86_64.msi"
    if (Test-Path $gaMsi) {
        Log "Installing QEMU guest agent..."
        Start-Process msiexec -ArgumentList "/i `"$gaMsi`" /qn" -Wait
    } else {
        Log "WARNING: guest agent MSI not found."
    }
}

# ── 2. Wait for network ───────────────────────────────────────────────────────
# The NetKVM driver install above is enough on most boots, but give the adapter
# time to come up before attempting any downloads.

Log "Waiting for network..."
$deadline = (Get-Date).AddSeconds(120)
while ((Get-Date) -lt $deadline) {
    if (Test-Connection -ComputerName 8.8.8.8 -Count 1 -Quiet -ErrorAction SilentlyContinue) {
        Log "Network is up."
        break
    }
    Start-Sleep 5
}
if (-not (Test-Connection -ComputerName 8.8.8.8 -Count 1 -Quiet -ErrorAction SilentlyContinue)) {
    Log "ERROR: No network after 120 s. Aborting."
    exit 1
}

# ── 3. Enable RDP ─────────────────────────────────────────────────────────────

Log "Enabling Remote Desktop..."
Set-ItemProperty `
    -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' `
    -Name fDenyTSConnections -Value 0
Enable-NetFirewallRule -DisplayGroup 'Remote Desktop'

# ── 4. Install Microsoft Office via ODT ──────────────────────────────────────

$officeDir = "$env:SystemDrive\office-install"
New-Item -ItemType Directory -Force -Path $officeDir | Out-Null

# setup.exe from this URL is the ODT itself (latest version, no version pinning).
Log "Downloading Office Deployment Tool..."
Invoke-WebRequest `
    -Uri 'https://officecdn.microsoft.com/pr/wsus/setup.exe' `
    -OutFile "$officeDir\setup.exe" `
    -UseBasicParsing

# Adjust Product ID and ExcludeApp to taste.
# O365ProPlusRetail installs Word, Excel, PowerPoint, Outlook, OneNote,
# Publisher, and Access.  Teams and OneDrive are excluded: Teams works poorly
# as a RemoteApp, and OneDrive is unnecessary in a VM.
@'
<Configuration>
  <Add OfficeClientEdition="64" Channel="Current">
    <Product ID="O365ProPlusRetail">
      <Language ID="en-us" />
      <ExcludeApp ID="Teams" />
      <ExcludeApp ID="OneDrive" />
      <ExcludeApp ID="Groove" />
    </Product>
  </Add>
  <Property Name="AUTOACTIVATE" Value="0" />
  <Display Level="None" AcceptEULA="TRUE" />
  <Updates Enabled="TRUE" />
</Configuration>
'@ | Set-Content "$officeDir\config.xml" -Encoding UTF8

Log "Downloading Office (~2 GB, this will take a while)..."
& "$officeDir\setup.exe" /download "$officeDir\config.xml"

Log "Installing Office..."
& "$officeDir\setup.exe" /configure "$officeDir\config.xml"

# ── 5. Clean up and reboot ────────────────────────────────────────────────────

Log "Cleaning up..."
Remove-Item -Recurse -Force $officeDir -ErrorAction SilentlyContinue

Log "Post-install complete. Rebooting in 10 s..."
shutdown /r /t 10 /c "Post-install reboot"
