# micro

| key             | value                                                                    |
| --------------- | ------------------------------------------------------------------------ |
| PKG_HOMEPAGE    | <https://micro-editor.github.io/>                                        |
| PKG_DESCRIPTION | Modern and intuitive terminal-based text editor                          |
| PKG_LICENSE     | MIT                                                                      |
| PKG_VERSION     | 2.0.14                                                                   |
| PKG_SRCURL      | <git+https://github.com/zyedidia/micro/archive/refs/tags/v2.0.14.tar.gz> |
| PKG_BASENAME    | micro-2.0.14                                                             |
| PKG_LANG        | go                                                                       |

## build

```sh
# VERSION=$(GOOS=$(go env GOHOSTOS) GOARCH=$(go env GOHOSTARCH) go run tools/build-version.go)
VERSION=${PKG_VERSION}
# HASH=$(git rev-parse --short HEAD)
HASH=04c5770
DATE=$(GOOS=$(go env GOHOSTOS) GOARCH=$(go env GOHOSTARCH) go run tools/build-date.go)
ADDITIONAL_GO_LINKER_FLAGS=$(GOOS=$(go env GOHOSTOS) GOARCH=$(go env GOHOSTARCH) go run tools/info-plist.go "$(go env GOOS)" "${VERSION}")
GOVARS="-X github.com/zyedidia/micro/v2/internal/util.Version=${VERSION} -X github.com/zyedidia/micro/v2/internal/util.CommitHash=${HASH} -X 'github.com/zyedidia/micro/v2/internal/util.CompileDate=$DATE'"

# go build -trimpath -ldflags "-s -w ${GOVARS} ${ADDITIONAL_GO_LINKER_FLAGS}" ./cmd/micro
## -trimpath appears looking like 'clang -v'
go build -ldflags "-s -w ${GOVARS} ${ADDITIONAL_GO_LINKER_FLAGS}" ./cmd/micro
install -Dt "${OUTPUT_DIR}/bin" micro
```
