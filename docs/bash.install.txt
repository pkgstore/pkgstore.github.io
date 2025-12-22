#!/usr/bin/env -S bash -euo pipefail
# -------------------------------------------------------------------------------------------------------------------- #
# INSTALLING AND UPDATING SCRIPTS
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
PFX="${4:-bash-}"; readonly PFX

# Variables.
TS="$( date '+%s' )"
UUID="$( cat '/proc/sys/kernel/random/uuid' )"
URI="https://raw.githubusercontent.com/${ORG}/${PFX}${APP}/refs/tags/${VER}"
API="/tmp/${UUID}.json"

# -------------------------------------------------------------------------------------------------------------------- #
# -----------------------------------------------------< SCRIPT >----------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

function package() {
  command -v 'jq' > '/dev/null' 2>&1 && return 0

  local os_id; os_id="$( . '/etc/os-release' && echo "${ID}" )";
  local pkg; pkg=('jq');

  function debian() {
    apt update && apt install --yes "${pkg[@]}"
  }

  case "${os_id}" in
    'debian') debian ;;
    *) echo >&2 'OS is not supported!'; exit 1 ;;
  esac
}

function backup() {
  [[ ! -f "${1}" ]] && return 0
  tar -cJf "${1}.${TS}.tar.xz" -C "${1%/*}" "${1##*/}"
}

function directory() {
  [[ -d "${1}" ]] && return 0
  mkdir -p "${1}"
}

function download() {
  curl -fsSLo "${2}" "${1}"
}

function app() {
  [[ "${2}" != *.sh ]] && return 0
  chmod +x "${1}/${2}"
}

function job() {
  [[ "${2}" != job.* ]] && return 0
  ln -sf "${1}/${2}" "/etc/cron.d/${2//./_}"
}

function setup() {
  download "${URI}/meta.json" "${API}"
  local name; name="$( jq -r '.name' "${API}" )"
  echo "--- ${name}"
  jq -c '.install.file[]' "${API}" | while read -r i; do
    local n; n="$( echo "${i}" | jq -r '.name' )"
    local p; p="$( echo "${i}" | jq -r '.path' )"
    echo "Installing '${n}'..."; backup "${p}/${n}"
    directory "${p}" && download "${URI}/${n}" "${p}/${n}" && app "${p}" "${n}" && job "${p}" "${n}"
  done
}

function main() { package && setup; }; main "$@"
