# lf

| key             | value                                               |
| --------------- | --------------------------------------------------- |
| PKG_HOMEPAGE    | <https://github.com/gokcehan/lf>                    |
| PKG_DESCRIPTION | Terminal file manager                               |
| PKG_LICENSE     | MIT                                                 |
| PKG_VERSION     | 35                                                  |
| PKG_SRCURL      | <https://github.com/gokcehan/lf/archive/r35.tar.gz> |
| PKG_BASENAME    | lf-r35                                              |
| BUILD_PREFIX    | ${GO_BUILD_DIR}                                     |

## Configure

```sh
setup_golang
```

## build

```sh
go build -ldflags="-X main.gVersion=r${PKG_VERSION}" -trimpath
install -Dt "${OUTPUT_DIR}/bin" lf
```
