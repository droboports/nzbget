_autoupdate() {
local VERSION="14.2-fs"
echo Downloading version ${VERSION}... >&3
"${prog_dir}/libexec/wget" -O "${prog_dir}/../nzbget.tgz" "https://github.com/droboports/nzbget/releases/download/v${VERSION}/nzbget.tgz"
setsid /bin/sh -c "echo Restarting NZBGet... >&3; /bin/sh ${prog_dir}/service.sh stop; sleep 5; /usr/bin/DroboApps.sh install" &
}
