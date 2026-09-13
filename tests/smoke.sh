#!/usr/bin/env sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_dir"

export APP_DATA_DIR="$repo_dir/.smoke-test"
compose="docker compose --project-name aalfath-ubuntu-desktop-smoke --env-file tests/smoke.env -f aalfath-ubuntu-desktop/docker-compose.yml -f tests/compose.smoke.yml"

cleanup() {
  $compose run --rm --no-deps --entrypoint /bin/sh volume-init \
    -c 'chown -R 1000:0 /data /sudoers.d' >/dev/null 2>&1 || true
  $compose down >/dev/null 2>&1 || true
  find "$APP_DATA_DIR" -depth -delete 2>/dev/null || true
}
trap cleanup EXIT INT TERM

mkdir -p "$APP_DATA_DIR"
cp aalfath-ubuntu-desktop/nginx.conf "$APP_DATA_DIR/nginx.conf"

$compose up -d

attempt=0
while [ "$attempt" -lt 90 ]; do
  health=$($compose ps --format json desktop 2>/dev/null | jq -r '.Health // empty')
  [ "$health" = "healthy" ] && break
  attempt=$((attempt + 1))
  sleep 2
done
test "${health:-}" = "healthy"

attempt=0
while [ "$attempt" -lt 30 ]; do
  authenticated_status=$(curl --silent --output /dev/null --write-out '%{http_code}' \
    --user 'kasm_user:umbrel-smoke-test-password' http://127.0.0.1:13390/ || true)
  [ "$authenticated_status" = "200" ] && break
  attempt=$((attempt + 1))
  sleep 1
done

anonymous_status=$(curl --silent --output /dev/null --write-out '%{http_code}' \
  http://127.0.0.1:13390/)
test "$anonymous_status" = "401"
test "$authenticated_status" = "200"
test "$($compose exec -T desktop sudo -n whoami)" = "root"
test "$($compose exec -T desktop stat -c '%U:%G:%a' /etc/sudoers.d/umbrel-kasm-user)" = "root:root:440"
test "$($compose exec -T desktop sh -c 'grep "^Seccomp:[[:space:]]*2$" /proc/self/status')" = "Seccomp:	2"
$compose exec -T desktop unshare --user --map-root-user true

$compose exec -T desktop sh -c \
  'printf umbrel-persistence-ok > /home/kasm-user/.umbrel-persistence-test'
$compose restart desktop

attempt=0
while [ "$attempt" -lt 90 ]; do
  health=$($compose ps --format json desktop 2>/dev/null | jq -r '.Health // empty')
  [ "$health" = "healthy" ] && break
  attempt=$((attempt + 1))
  sleep 2
done
test "${health:-}" = "healthy"
test "$($compose exec -T desktop cat /home/kasm-user/.umbrel-persistence-test)" = "umbrel-persistence-ok"

echo "Runtime smoke test passed: authentication, sudo, Chromium sandbox namespaces, and persistence"
