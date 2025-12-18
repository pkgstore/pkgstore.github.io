<#PSScriptInfo
.VERSION      0.1.0
.GUID         9700053a-16e7-44d5-9654-ae013214cba7
.AUTHOR       Kai Kimera
.AUTHOREMAIL  mail@kaikim.ru
.TAGS
.LICENSEURI   https://choosealicense.com/licenses/mit/
.PROJECTURI
#>

#Requires -Version 7.4

<#
.SYNOPSIS
Sending emails with requests using SMTP.

.DESCRIPTION

.EXAMPLE


.EXAMPLE


.EXAMPLE


.LINK

#>

# -------------------------------------------------------------------------------------------------------------------- #
# CONFIGURATION
# -------------------------------------------------------------------------------------------------------------------- #

param(
  [Parameter(Mandatory)][string[]]$App,
  [string]$Org = 'pkgstore',
  [string]$Pfx = 'pwsh-'
)

$TS = (Get-Date -UFormat '%s');

# -------------------------------------------------------------------------------------------------------------------- #
# -----------------------------------------------------< SCRIPT >----------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

function Compress-File([string]$In, [string]$Out) {
  Compress-Archive -LiteralPath "${In}" -DestinationPath "${Out}.${TS}.zip"
}

function Install-App {
  $App.ForEach({
    $URI = "https://raw.githubusercontent.com/${Org}/${Pfx}${_}/refs/heads/main"
    $META = (Invoke-RestMethod -Uri "${URI}/meta.json");
    $META.install.file.ForEach({
      if (-not (Test-Path -LiteralPath "$($_.path)")) {
        New-Item -Path "$($_.path)" -ItemType "Directory" | Out-Null
      }
      if (Test-Path -LiteralPath "$($_.path)\$($_.name)") {
        Compress-File -In "$($_.path)\$($_.name)" -Out "$($_.path)\$($_.name)"
      }
      Invoke-WebRequest -Uri "${URI}/$($_.name)" -OutFile "$($_.path)"
    })
  })
}

function Start-Script() {
  Install-App
}; Start-Script
