_autoupdate() {
wget -O "${prog_dir}/../nzbget.tgz" "https://github.com/droboports/nzbget/releases/download/v14.2/nzbget.tgz"
/bin/sh "${prog_dir}/service.sh" stop
sleep 5
/usr/bin/DroboApps.sh install
}
