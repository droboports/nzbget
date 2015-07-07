#!/usr/bin/env sh
#
# Nzbget update script

prog_dir="$(dirname "$(realpath "${0}")")"
name="$(basename "${prog_dir}")"
tmp_dir="/tmp/DroboApps/${name}"
logfile="${tmp_dir}/update.log"

# boilerplate
if [ ! -d "${tmp_dir}" ]; then mkdir -p "${tmp_dir}"; fi
exec 3>&1 4>&2 1>> "${logfile}" 2>&1
echo "$(date +"%Y-%m-%d %H-%M-%S"):" "${0}" "${@}"
set -o errexit  # exit on uncaught error code
set -o nounset  # exit on unset variable
set -o pipefail # propagate last error code on pipe
set -o xtrace   # enable script tracing

rm -vf "${tmp_dir}/update-${NZBUP_BRANCH}.sh"
"${prog_dir}/libexec/wget" -O "${tmp_dir}/update-${NZBUP_BRANCH}.sh" "https://raw.githubusercontent.com/droboports/nzbget/master/src/update-${NZBUP_BRANCH}.sh"
. "${tmp_dir}/update-${NZBUP_BRANCH}.sh"
_autoupdate
