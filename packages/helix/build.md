# helix

<https://docs.helix-editor.com/building-from-source.html>

| key                  | value                                                                    |
| -------------------- | ------------------------------------------------------------------------ |
| PKG_HOMEPAGE         | <https://helix-editor.com/>                                              |
| PKG_DESCRIPTION      | A post-modern modal text editor written in rust                          |
| PKG_LICENSE          | MPL-2.0                                                                  |
| PKG_VERSION          | 25.01.1                                                                  |
| PKG_NAME             | hx                                                                       |
| PKG_SRCURL           | <https://github.com/helix-editor/helix/archive/refs/tags/25.01.1.tar.gz> |
| PKG_GIT_BRANCH       | 25.01.1                                                                  |
| PKG_SUGGESTS         | helix-grammars                                                           |
| PKG_BUILD_IN_SRC     | true                                                                     |
| PKG_AUTO_UPDATE      | true                                                                     |
| PKG_RM_AFTER_INSTALL | opt/helix/runtime/grammars/sources/                                      |
| PKG_DEPENDS          | zlib                                                                     |
| PKG_BASENAME         | helix-25.01.1                                                            |
| PKG_LANG             | rust                                                                     |

## Build

```sh
# export RUSTFLAGS="-C link-arg=-s -C opt-level=s -C lto=true"

## If you are using the musl-libc standard library instead of glibc
## the following environment variable must be set during the build
## to ensure tree-sitter grammars can be loaded correctly:
export RUSTFLAGS="-C target-feature=-crt-static"

## If you do not want to fetch or build grammars, set an environment variable
# export HELIX_DISABLE_AUTO_GRAMMAR_BUILD=

cargo build --target="${CARGO_BUILD_TARGET}" --release

DATA_DIR=${OUTPUT_DIR}/lib/helix
mkdir -p "${DATA_DIR}"

install "target/${CARGO_BUILD_TARGET}/release/${PKG_NAME}" -D "${DATA_DIR}/${PKG_NAME}"
cp -r runtime "${DATA_DIR}/runtime"
rm -rf "${DATA_DIR}/runtime/grammars/sources"
ln -snf ../lib/helix/hx "${OUTPUT_DIR}/bin/hx"
```
