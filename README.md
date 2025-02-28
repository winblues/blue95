# blue95 &nbsp; [![bluebuild build badge](https://github.com/ledif/blue95/actions/workflows/build.yml/badge.svg)](https://github.com/ledif/blue95/actions/workflows/build.yml) ![b](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fgithub.com%2Fipitio%2Fbackage%2Fraw%2Findex%2Fledif%2Fblue95%2Fblue95.json&query=%24.downloads&label=total%20pulls)


> A desktop for your childhood home's computer room.

![main-screenshot](https://github.com/user-attachments/assets/4a643bd3-82e8-4c63-91fb-c77f6fdd801c)

Blue95 is a modern and lightweight desktop experience that is reminiscent of a bygone era of computing.
Based on Fedora Atomic Xfce with the [Chicago95](https://github.com/grassmunk/Chicago95) theme.

For more screenshots, see [screenshots.md](https://github.com/ledif/blue95/blob/main/docs/screenshots.md).

## Project Goals

- Match upstream Fedora Xfce in terms of core system components and update schedule.
- Pull in tweaks from [Universal Blue](https://github.com/ublue-os) (e.g. codecs, automatic updates, etc) to produce a more usable out-of-the box experience.
- Provide an aesthetic rooted in a bygone era of computing.

**Non goals**:
- Faithful reproduction of design elements from decades old operating systems. Whenever usability and exact replication are at odds, usability and accessibility will generally be preferred.


## Installation

### From ISO

Visit https://blue95.neocities.org for links to the latest ISOs.

## From Other Atomic Desktops
If you are currently using an atomic desktop, you can rebase to the latest blue95 image.

- First rebase to the unsigned image, to get the proper signing keys and policies installed:
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/winblues/blue95:latest
  ```
- Reboot and then rebase to the signed image, like so:
  ```
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/winblues/blue95:latest
  ```

It is recommended to create a new user after rebasing.

## Shoutouts
- [@grassmunk](https://github.com/grassmunk)/[@dominichayesferen](https://github.com/dominichayesferen) for [Chicago95](https://github.com/grassmunk/Chicago95) and [Chicagofier](https://github.com/dominichayesferen/Chicagofier) respectively
- [BlueBuild](https://github.com/blue-build), [Universal Blue](https://github.com/ublue-os) and [Fedora](https://fedoraproject.org)
- The [Xfce](https://www.xfce.org/) team
 
