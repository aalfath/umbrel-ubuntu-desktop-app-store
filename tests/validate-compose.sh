#!/usr/bin/env sh
set -eu

export APP_DATA_DIR="${APP_DATA_DIR:-/tmp/aalfath-ubuntu-desktop-test}"
export APP_PASSWORD="${APP_PASSWORD:-test-password-do-not-use}"

docker compose \
  -f aalfath-ubuntu-desktop/docker-compose.yml \
  -f tests/compose.test.yml \
  config --quiet

echo "Compose validation passed"
