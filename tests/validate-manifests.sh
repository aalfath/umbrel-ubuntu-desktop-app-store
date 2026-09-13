#!/usr/bin/env sh
set -eu

store="umbrel-app-store.yml"
app="aalfath-ubuntu-desktop/umbrel-app.yml"
compose="aalfath-ubuntu-desktop/docker-compose.yml"

yq eval '.' "$store" >/dev/null
yq eval '.' "$app" >/dev/null
yq eval '.' "$compose" >/dev/null

test "$(yq '.id' "$store")" = "aalfath"
test "$(yq '.id' "$app")" = "aalfath-ubuntu-desktop"
test "$(yq '.manifestVersion' "$app")" = "1"
test "$(yq '.port' "$app")" = "3390"
test "$(yq '.defaultUsername' "$app")" = "kasm_user"
test "$(yq '.deterministicPassword' "$app")" = "true"
test "$(yq '.services.app_proxy.environment.APP_PORT' "$compose")" = "8080"
test "$(yq '.services.desktop.environment.VNC_PW' "$compose")" = '${APP_PASSWORD}'
test "$(yq '.services.desktop.volumes[0]' "$compose")" = '${APP_DATA_DIR}/data/home:/home/kasm-user'

echo "Manifest validation passed"
