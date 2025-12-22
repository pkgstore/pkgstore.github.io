<#PSScriptInfo
.VERSION      0.1.0
.GUID         9700053a-16e7-44d5-9654-ae013214cba7
.AUTHOR       Kai Kimera
.AUTHOREMAIL  mail@kaikim.ru
.TAGS         pwsh powershell install
.LICENSEURI   https://choosealicense.com/licenses/mit/
.PROJECTURI
#>

#Requires -Version 7.4

<#
.SYNOPSIS
Installing scripts.

.DESCRIPTION
The file allows you to install scripts in a special directory, including additional files for maintenance.
#>

# -------------------------------------------------------------------------------------------------------------------- #
# CONFIGURATION
# -------------------------------------------------------------------------------------------------------------------- #

param(
  [Parameter(Mandatory)][string]$App,
  [Parameter(Mandatory)][string]$Ver,
  [string]$Org = 'pkgstore',
  [string]$Pfx = 'pwsh-'
)

$TS = (Get-Date -UFormat '%s');
$UUID = (New-Guid)
$URI = "https://raw.githubusercontent.com/${Org}/${Pfx}${App}/refs/tags/${Ver}"
$API = "${env:TEMP}\${UUID}.json"

# -------------------------------------------------------------------------------------------------------------------- #
# -----------------------------------------------------< SCRIPT >----------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

function Get-Api([string]$Uri, [string]$OutFile) {
  Invoke-RestMethod -Uri "${Uri}" -OutFile "${OutFile}"
}

function Open-Api([string]$Path) {
  Get-Content -Path "${Path}" -Raw | ConvertFrom-Json
}

function New-Directory([string]$Path) {
  if (Test-Path -LiteralPath "${Path}") { return }
  New-Item -Path "${Path}" -ItemType 'Directory' | Out-Null
}

function Get-File([string]$Uri, [string]$OutFile) {
  Invoke-WebRequest -Uri "${Uri}" -OutFile "${OutFile}"
}

function Backup-File([string]$Path) {
  if (-not (Test-Path -LiteralPath "${Path}")) { return }
  Compress-Archive -LiteralPath "${Path}" -DestinationPath "${Path}.${TS}.zip"
}

function Import-Job([string]$Path, [string]$Name) {
  if (-not ((Split-Path -Path "${Path}" -Leaf) -like 'job.*')) { return }
  if (Get-ScheduledTask | Where-Object { $_.TaskName -eq "${Name}" }) { return }
  Register-ScheduledTask -Xml (Get-Content "${Path}" | Out-String) -TaskName "${Name}" | Out-Null
}

function Install-App {
  try {
    Get-Api "${URI}/meta.json" "${API}"
    $Meta = (Open-Api "${API}")
    $Name = $Meta.name
    Write-Host "--- ${Name}"
    $Meta.install.file.ForEach({
      $n = "$($_.name)"; $p = "$($_.path)"
      Write-Host "Installing '${n}'..."; Backup-File "${p}\${n}"
      New-Directory "${p}" && Get-File "${URI}/${n}" "${p}" && Import-Job "${p}\${n}" "${Name}"
    })
  } catch {
    $StatusCode = $_.Exception.Response.StatusCode.Value__
    $StatusCode -eq '404' ? (Write-Warning 'Resource not found (404)!') : (Write-Error "An error occurred: ${_}")
  }
}

function Start-Script() { Install-App }; Start-Script
