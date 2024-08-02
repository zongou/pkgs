# Build Busybox for android

| Variable                             | Meaning                  |
| ------------------------------------ | ------------------------ |
| CC="${CC}"                           | target platform compiler |
| HOSTCC=gcc                           | build platform compiler  |
| CROSS_COMPILER="aarch64-linux-musl-" | cross compiler prefix    |

## Configure

```sh
make <...> menuconfig

# cli
make config
```

### Minimal adjustion to build

- Settings
  - [ ] Support utmp file
  - [ ] Support writing pidfiles
  - [ ] Drop SUID state for most applets
  - [ ] SHA1: Use hardware accelerated instructions if possible @v1.37
  - [ ] SHA256: Use hardware accelerated instructions if possible (not compatible with i686)
- CoreUtils
  - [ ] hostid
  - [ ] logname @v1.36
  - [ ] sync @v1.36
- Console Utilities
  - [ ] loadfont
  - [ ] setfont
- Login/Password Management Utilities
  - [ ] su
- Linux System Utilities
  - [ ] fsck.minix
  - [ ] ipcrm
  - [ ] ipcs
  - [ ] mkfs.minix
  - [ ] swapon
  - [ ] swapoff
- Miscellanrous Utilities
  - [ ] adjtimex @v1.36.1
  - [ ] conspy
  - [ ] seedrng @v1.36
- Network Utilities
  - [ ] Enable IPv6 support
  - [ ] ether-wake
  - [ ] nslookup
  - [ ] tc @v1.37
- Shells
  - [ ] hush
  - [ ] Internal shell for embedded script support @v1.36
- System Logging Utilities
  - [ ] (all)

## Optimized adjustion

- Settings

  - [x] Tab completion.
  - [x] Username completion
  - [x] Fancy shell prompts
  - (0) Range of supported Unicode characters
  - [x] Allow wide Unicode characters on output

- Arhives Utilities:

  - [x] Enable compression levels
  - [x] Optimise lzma for speed

- CoreUtils

- Console Utilities

- Editors:

  - [x] Allow to display 8-bit chars (otherwise show dots)

- Login/Password Management Utilities

- Linux System Utilities

- Miscellanrous Utilities

- Network Utilities

  - (8080) httpd Default port
  - (8023) telnetd Default port

- Shells

- System Logging Utilities

## Build

```sh
make <...> busybox_unstripped
```

## Install

busybox image install to dir

```sh
make <...> install CONFIG_PREFIX="${OUTPUT_DIR}"
```

## Examples

- <https://github.com/termux/termux-packages/blob/master/packages/busybox/build.sh>
- <https://github.com/rsepassi/simplelinux/blob/main/busybox/build.sh>
