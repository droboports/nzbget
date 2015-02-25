_autoupdate() {
echo wget -o "${prog_dir}/../nzbget.tgz" "https://github.com/droboports/nzbget/releases/download/v14.2/nzbget.tgz" >&3
echo /bin/sh "${prog_dir}/service.sh" stop
sleep 1
echo /usr/bin/DroboApps.sh install
}
