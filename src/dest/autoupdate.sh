#!/usr/bin/env sh
#
# Nzbget update script

prog_dir="$(dirname $(realpath ${0}))"
name="$(basename ${prog_dir})"
logfile="/tmp/DroboApps/${name}/update.log"

# script hardening
set -o errexit  # exit on uncaught error code
set -o nounset  # exit on unset variable
set -o pipefail # propagate last error code on pipe

# ensure log folder exists
if ! grep -q ^tmpfs /proc/mounts; then mount -t tmpfs tmpfs /tmp; fi
logfolder="$(dirname ${logfile})"
if [[ ! -d "${logfolder}" ]]; then mkdir -p "${logfolder}"; fi

# redirect all output to logfile
exec 3>&1 1>> "${logfile}" 2>&1

# log current date, time, and invocation parameters
echo $(date +"%Y-%m-%d %H-%M-%S"): ${0} ${@}

# enable script tracing
set -o xtrace

export

echo rm -vf "${logfolder}/update-${NZBUP_BRANCH}.sh" >&3
echo "${prog_dir}/libexec/wget" -o "${logfolder}/update-${NZBUP_BRANCH}.sh" "https://raw.githubusercontent.com/droboports/nzbget/master/src/update-${NZBUP_BRANCH}.sh" >&3
echo source "${logfolder}/update-${NZBUP_BRANCH}.sh" >&3
source "${logfolder}/update-${NZBUP_BRANCH}.sh"
echo _auto_update >&3
_auto_update

echo "Update completed. See ${logfile} for a detailed log." >&3
