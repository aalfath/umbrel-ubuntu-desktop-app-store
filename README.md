# Ubuntu Desktop for umbrelOS

A minimal Umbrel Community App Store containing a persistent Ubuntu Jammy
desktop powered by KasmVNC.

## Install

1. Open **App Store** in umbrelOS.
2. Open the menu, choose **Community App Stores**, and add:

   `https://github.com/aalfath/umbrel-ubuntu-desktop-app-store`

3. Open the **Aalfath Desktop** store and install **Ubuntu Desktop**.
4. Open the app and sign in with username `kasm_user`. umbrelOS shows the
   app-specific password on the app page.

The first installation downloads a large image (approximately 4 GB
compressed), so allow several minutes and make sure the Umbrel has enough free
storage.

## Persistence and security

The Kasm user's complete home directory is stored under the app's persistent
Umbrel data directory. Documents, settings, browser profiles, and per-user
software therefore survive restarts and upgrades. Uninstalling the app from
umbrelOS removes its application data after Umbrel's normal confirmation.

The Linux account inside the desktop is named `kasm-user` and has passwordless
sudo access. Run administrative commands with `sudo`; there is no root
password. Packages installed into the container's system directories with
`apt` survive normal restarts, but not an app update that replaces the
container. Files and per-user applications stored in the home directory remain
persistent.

KasmVNC authentication is enabled with Umbrel's generated deterministic app
password. Although `kasm-user` can become root inside its own container, the
container is not run in Docker privileged mode and has no Docker socket or host
filesystem mounts. Treat the desktop like any machine on your LAN: use it only
on a trusted network or through a private VPN, keep umbrelOS updated, and do
not port-forward it directly to the internet.

## Development and tests

The repository pins all runtime images by SHA-256 digest and runs manifest and
Compose validation in GitHub Actions. To run the checks locally:

```sh
./tests/validate-manifests.sh
./tests/validate-compose.sh
```

For a runtime smoke test, start the Compose stack with Umbrel-style test
environment values and verify the authenticated KasmVNC endpoint, passwordless
sudo, and persistent home storage:

```sh
./tests/smoke.sh
```

The CI checks deliberately avoid pulling the multi-gigabyte desktop image on
every commit.

## Upstream

- [Kasm Ubuntu Jammy Desktop](https://hub.docker.com/r/kasmweb/ubuntu-jammy-desktop)
- [Kasm Workspaces images](https://github.com/kasmtech/workspaces-images)
- [Umbrel Community App Store template](https://github.com/getumbrel/umbrel-community-app-store)

This repository packages upstream software and is not affiliated with Umbrel
or Kasm Technologies.
