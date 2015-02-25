_autoupdate() {
local VERSION="14.2"
echo Downloading version ${VERSION}...
"${prog_dir}/libexec/wget" -O "${prog_dir}/../nzbget.tgz" "https://github.com/droboports/nzbget/releases/download/v${VERSION}/nzbget.tgz"
(
  echo Restarting NZBGet...
  sleep 1
  /bin/sh "${prog_dir}/service.sh" stop
  sleep 5
  /usr/bin/DroboApps.sh install
) &
disown -h $!
}
