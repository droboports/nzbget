_autoupdate() {
local VERSION="15.0"
echo "Downloading version ${VERSION}..." >&3
"${prog_dir}/libexec/wget" -O "${tmp_dir}/nzbget.tgz" "https://github.com/droboports/nzbget/releases/download/v${VERSION}/nzbget.tgz" >> "${tmp_dir}/wget.log" 2>&1
if [ $? -eq 0 ]; then
  mv "${tmp_dir}/nzbget.tgz" "/mnt/DroboFS/Shares/DroboApps/"
  setsid /bin/sh -c "echo Updating NZBGet... >&3; /usr/bin/DroboApps.sh install" &
fi
}
