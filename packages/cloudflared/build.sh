PKG_HOMEPAGE=https://github.com/cloudflare/cloudflared
PKG_DESCRIPTION="A tunneling daemon that proxies traffic from the Cloudflare network to your origins"
PKG_LICENSE="Apache-2.0"
PKG_VERSION="2024.8.2"
PKG_SRCURL=https://github.com/cloudflare/cloudflared/archive/refs/tags/${PKG_VERSION}.tar.gz
PKG_BASENAME=cloudflared-${PKG_VERSION}
BUILD_PREFIX=${GO_BUILD_DIR}

build() {
	setup_golang
	DATE=$(date -u '+%Y.%m.%d-%H:%M UTC')
	go build -v -ldflags "-X \"main.Version=$PKG_VERSION\" -X \"main.BuildTime=$DATE\"" \
		./cmd/cloudflared
	install -Dm700 -t "${OUTPUT_DIR}/bin" cloudflared
}
