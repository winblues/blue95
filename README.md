# blue95 &nbsp; [![bluebuild build badge](https://github.com/ledif/blue95/actions/workflows/build.yml/badge.svg)](https://github.com/ledif/blue95/actions/workflows/build.yml)

> A desktop for your childhood home's computer room.

Blue95 is a modern Fedora Atomic Desktop using the Xfce Desktop environment with the [Chicago95](https://github.com/grassmunk/Chicago95) theme.
Its goal is to provide a modern and lightweight Linux experience with that reminds us of a bygone era of computing.

## Installation

The only way to install currently is to rebase from an existing atomic Fedora installation to the latest build.
ISOs will be available at some point.

- First rebase to the unsigned image, to get the proper signing keys and policies installed:
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/ledif/blue95:latest
  ```
- Reboot and then rebase to the signed image, like so:
  ```
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/ledif/blue95:latest
  ```

The `latest` tag will automatically point to the latest build.


## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/ledif/blue95
```

## Shoutouts
- [@grassmunk](https://github.com/grassmunk/Chicago95)/[@dominichayesferen](https://github.com/grassmunk/Chicago95) for [Chicago95](https://github.com/grassmunk/Chicago95) and [Chicagofier](https://github.com/dominichayesferen/Chicagofier) respectively
- [BlueBuild](https://github.com/blue-build), [Universal Blue](https://github.com/ublue-os) and [Fedora](https://fedoraproject.org)
- The [Xfce](https://www.xfce.org/) team
 
