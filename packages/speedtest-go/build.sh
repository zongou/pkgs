PKG_HOMEPAGE=https://github.com/showwin/speedtest-go/
PKG_DESCRIPTION="Command line interface to test internet speed using speedtest.net"
PKG_LICENSE="MIT"

PKG_VERSION="1.7.5"
PKG_BASENAME=speedtest-go-${PKG_VERSION}
PKG_EXTNAME=.tar.gz
PKG_SRCURL=https://github.com/showwin/speedtest-go/archive/refs/tags/v${PKG_VERSION}.tar.gz

build() {
	setup_golang
	go build -ldflags='-w -s'
	install -Dt "${OUTPUT_DIR}/bin" speedtest-go
}
