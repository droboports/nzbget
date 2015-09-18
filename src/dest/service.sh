#!/usr/bin/env sh
#
# NZBGet service

# import DroboApps framework functions
. /etc/service.subr

framework_version="2.1"
name="nzbget"
version="15.0-1"
description="NZBGet is a usenet download manager"
depends=""
webui="WebUI"

prog_dir="$(dirname "$(realpath "${0}")")"
daemon="${prog_dir}/bin/nzbget"
conffile="${prog_dir}/etc/nzbget.conf"
tmp_dir="/tmp/DroboApps/${name}"
pidfile="${tmp_dir}/pid.txt"
logfile="${tmp_dir}/log.txt"
statusfile="${tmp_dir}/status.txt"
errorfile="${tmp_dir}/error.txt"
nicelevel=19

# backwards compatibility
if [ -z "${FRAMEWORK_VERSION:-}" ]; then
  framework_version="2.0"
  . "${prog_dir}/libexec/service.subr"
fi

start() {
  "${daemon}" --configfile "${conffile}" --daemon
  renice "${nicelevel}" $(cat "${pidfile}")
}

stop() {
  "${daemon}" --configfile "${conffile}" --quit
}

force_stop() {
  /sbin/start-stop-daemon -K -s 9 -x "${daemon}" -p "${pidfile}" -v
}

reload() {
  "${daemon}" --configfile "${conffile}" --reload
}

# boilerplate
if [ ! -d "${tmp_dir}" ]; then mkdir -p "${tmp_dir}"; fi
exec 3>&1 4>&2 1>> "${logfile}" 2>&1
STDOUT=">&3"
STDERR=">&4"
echo "$(date +"%Y-%m-%d %H-%M-%S"):" "${0}" "${@}"
set -o errexit  # exit on uncaught error code
set -o nounset  # exit on unset variable
set -o xtrace   # enable script tracing

main "${@}"
