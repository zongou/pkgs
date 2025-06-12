# zlib

| key             | value                                                                                   |
| --------------- | --------------------------------------------------------------------------------------- |
| PKG_HOMEPAGE    | <https://www.zlib.net/>                                                                 |
| PKG_DESCRIPTION | Compression library implementing the deflate compression method found in gzip and PKZIP |
| PKG_LICENSE     | ZLIB                                                                                    |
| PKG_VERSION     | 1.3.1                                                                                   |
| PKG_BASENAME    | zlib-1.3.1                                                                              |
| PKG_SRCURL      | <https://zlib.net/zlib-1.3.1.tar.xz>                                                    |

## Configure

```sh
./configure --static --archs="-fPIC" --prefix="${OUTPUT_DIR}"
```

## Build

```sh
make -j"${JOBS}" install
```

## Check

```sh
test -f "${OUTPUT_DIR}/lib/libz.a"
```
