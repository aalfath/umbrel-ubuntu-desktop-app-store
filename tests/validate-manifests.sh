#!/usr/bin/env sh
set -eu

store="umbrel-app-store.yml"
app="aalfath-ubuntu-desktop/umbrel-app.yml"
compose="aalfath-ubuntu-desktop/docker-compose.yml"

yq eval '.' "$store" >/dev/null
yq eval '.' "$app" >/dev/null
yq eval '.' "$compose" >/dev/null
jq empty aalfath-ubuntu-desktop/chromium-seccomp.json

test "$(yq '.id' "$store")" = "aalfath"
test "$(yq '.id' "$app")" = "aalfath-ubuntu-desktop"
test "$(yq '.manifestVersion' "$app")" = "1"
test "$(yq '.port' "$app")" = "3390"
test "$(yq '.defaultUsername' "$app")" = "kasm_user"
test "$(yq '.deterministicPassword' "$app")" = "true"
test "$(yq '.services.app_proxy.environment.APP_PORT' "$compose")" = "8080"
test "$(yq '.services.desktop.environment.VNC_PW' "$compose")" = '${APP_PASSWORD}'
test "$(yq '.services.desktop.volumes[0]' "$compose")" = '${APP_DATA_DIR}/data/home:/home/kasm-user'
test "$(yq '.services.desktop.volumes[1]' "$compose")" = '${APP_DATA_DIR}/sudoers.d:/etc/sudoers.d:ro'
test "$(yq '.services.desktop.security_opt[0]' "$compose")" = 'seccomp=./chromium-seccomp.json'
test "$(yq '.services.desktop.security_opt[1]' "$compose")" = 'apparmor=unconfined'
test "$(yq '.services.volume-init.volumes[1]' "$compose")" = '${APP_DATA_DIR}/sudoers.d:/sudoers.d'
test "$(yq '.services.volume-init.command[2]' "$compose" | grep -c 'kasm-user ALL=(ALL:ALL) NOPASSWD: ALL')" = "1"
test "$(jq '[.syscalls[] | select(.action == "SCMP_ACT_ALLOW") | .names[]] | any(. == "clone")' aalfath-ubuntu-desktop/chromium-seccomp.json)" = "true"
test "$(jq '[.syscalls[] | select(.action == "SCMP_ACT_ALLOW") | .names[]] | any(. == "clone3")' aalfath-ubuntu-desktop/chromium-seccomp.json)" = "true"
test "$(jq '[.syscalls[] | select(.action == "SCMP_ACT_ALLOW") | .names[]] | any(. == "unshare")' aalfath-ubuntu-desktop/chromium-seccomp.json)" = "true"

echo "Manifest validation passed"
