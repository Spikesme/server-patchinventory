param(
  [string]$OutDir = "C:\ProgramData\PatchInventory",

  # Zentraler Ablageort (UNC). Beispiel:
  # "\\DEIN-DC\PatchInventory"
  [string]$CentralShare = "\\WSV001\PatchInventory"
)

$ErrorActionPreference = "Stop"

$computer = $env:COMPUTERNAME

New-Item -ItemType Directory -Path $OutDir -Force | Out-Null

# OS Infos (ohne DMTF-Konvertierung)
$os = Get-CimInstance -ClassName Win32_OperatingSystem
$cs = Get-CimInstance -ClassName Win32_ComputerSystem

# IP Address (primary IPv4 with default gateway)
$ipAddress = $null
try {
  $ipAddress = (Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway } |
    Select-Object -First 1 -ExpandProperty IPv4Address).IPAddress
} catch {
  $ipAddress = $null
}


# Letzter Neustart (ISO 8601 ohne Zeitzone, "s" Format)
$lastReboot = $null
try {
  if ($os.LastBootUpTime) {
    $lastReboot = (Get-Date $os.LastBootUpTime).ToString("s")  # z.B. 2026-01-02T09:15:00
  }
} catch {
  $lastReboot = $null
}

# Hotfixes / KBs (mit normalisiertem Installationsdatum)
$hotfixes = Get-HotFix | Sort-Object HotFixID | ForEach-Object {
  $installed = $null
  try {
    if ($_.InstalledOn -and ($_.InstalledOn.ToString().Trim() -ne "")) {
      $installed = (Get-Date $_.InstalledOn).ToString("yyyy-MM-dd")
    }
  } catch {
    $installed = $null
  }

  [pscustomobject]@{
    HotFixID    = $_.HotFixID
    InstalledOn = $installed
    Description = $_.Description
  }
}

$data = [pscustomobject]@{
  ComputerName = $computer
  Domain       = $cs.Domain
  IPAddress    = $ipAddress
  LastReboot   = $lastReboot
  OS           = [pscustomobject]@{
    Caption     = $os.Caption
    Version     = $os.Version
    BuildNumber = $os.BuildNumber
  }
  Hotfixes = $hotfixes
}

# Lokale Dateien
$outFile       = Join-Path $OutDir ("{0}.json" -f $computer)
$outFileLatest = Join-Path $OutDir ("{0}_latest.json" -f $computer)

$json = $data | ConvertTo-Json -Depth 6
$json | Set-Content -Path $outFile -Encoding UTF8
$json | Set-Content -Path $outFileLatest -Encoding UTF8

# --- Zentral kopieren (nur latest, damit es "aktueller Stand" bleibt) ---
try {
  if (-not [string]::IsNullOrWhiteSpace($CentralShare)) {
    # Share-Ordner anlegen, falls möglich
    if (-not (Test-Path -Path $CentralShare)) {
      New-Item -ItemType Directory -Path $CentralShare -Force | Out-Null
    }

    $centralLatest = Join-Path $CentralShare ("{0}_latest.json" -f $computer)

    Copy-Item -Path $outFileLatest -Destination $centralLatest -Force
  }
} catch {
  # Task soll NICHT failen, nur weil Copy mal hakt (Netz/ACL/Share down)
  $msg = $_.Exception.Message
  $logDir = Join-Path $OutDir "Logs"
  New-Item -ItemType Directory -Path $logDir -Force | Out-Null
  Add-Content -Path (Join-Path $logDir "copy_errors.log") -Value ("[{0}] {1} -> {2}" -f (Get-Date).ToString("s"), $computer, $msg)
}
