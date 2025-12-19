#!/usr/bin/env -S bash -euo pipefail
# -------------------------------------------------------------------------------------------------------------------- #
# BASH: INSTALLING AND UPDATING SCRIPTS
# -------------------------------------------------------------------------------------------------------------------- #
# @package    Bash
# @author     Kai Kimera <mail@kai.kim>
# @license    MIT
# @version    0.1.0
# @link
# -------------------------------------------------------------------------------------------------------------------- #

(( EUID != 0 )) && { echo >&2 'This script should be run as root!'; exit 1; }

# -------------------------------------------------------------------------------------------------------------------- #
# CONFIGURATION
# -------------------------------------------------------------------------------------------------------------------- #

# Parameters.
APP="${1:?}"; readonly APP
VER="${2:?}"; readonly VER
ORG="${3:-pkgstore}"; readonly ORG
PFX="${4:-pwsh-}"; readonly PFX

TS="$( date '+%s' )"

function package() {
  local os_id; os_id="$( . '/etc/os-release' && echo "${ID}" )";
  local p; p=('jq');

  function debian() {
    apt update && apt install --yes "${p[@]}"
  }

  case "${os_id}" in
    'debian') debian ;;
    *) echo >&2 'OS is not supported!'; exit 1 ;;
  esac
}

function download() {
  curl -fsSLo "${2}" "${1}"
}

function directory() {
  [[ ! -d "${1}" ]] && mkdir -p "${1}"
}

function backup() {
  [[ -f "${1}" ]] && tar -cJf "${1}.${TS}.tar.xz" -C "${1%/*}" "${1##*/}"
}

function job() {
  [[ "${2}" == job.* ]] && ln -sf "${1}/${2}" "/etc/cron.d/${2//./_}"
}

function app() {
  [[ "${2}" == *.sh ]] && chmod +x "${1}/${2}"
}

function installing() {
  local uri; uri="https://raw.githubusercontent.com/${ORG}/${PFX}${APP}/refs/tags/${VER}"
  local meta; meta="$( curl -s "${uri}/meta.json" )"
  local name; name="$( $meta | jq -r '.name' )"
  local desc; desc="$( $meta | jq -r '.description' )"
  jq -c '.install.file[]' "${meta}" | while read -r i; do
    local n; n=$( echo "$i" | jq -r '.name' )
    local p; p=$( echo "$i" | jq -r '.path' )
    directory "${p}" && download "${uri}/${n}" "${p}/${n}"
    job "${p}" "${n}" && app "${p}" "${n}"
  done
}

function main() { installing; }; main "$@"
