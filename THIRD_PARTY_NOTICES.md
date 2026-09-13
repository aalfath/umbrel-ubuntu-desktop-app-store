# Third-party notices

`aalfath-ubuntu-desktop/chromium-seccomp.json` is derived from the Moby
`profiles` default seccomp policy at commit
`61eaf32614c7c71b60bd8927d3e6a4ffc8ff1f31` and modified to permit `clone`,
`clone3`, and `unshare` for Chromium/Electron user-namespace sandboxing.

Source: https://github.com/moby/profiles/blob/61eaf32614c7c71b60bd8927d3e6a4ffc8ff1f31/seccomp/default.json

Moby `profiles` is licensed under the Apache License 2.0. A copy is provided
at `LICENSES/Apache-2.0.txt`.
