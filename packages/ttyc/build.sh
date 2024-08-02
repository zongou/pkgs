PKG_HOMEPAGE=https://github.com/Depau/ttyc
PKG_DESCRIPTION="ttyd protocol client"
PKG_LICENSE="GPL-3.0"
PKG_VERSION="0.4"
PKG_REVISION=3
PKG_SRCURL=https://github.com/Depau/ttyc/archive/refs/tags/ttyc-v${PKG_VERSION}.tar.gz
PKG_BASENAME=ttyc-ttyc-v${PKG_VERSION}

# termux_step_pre_configure() {
# 	termux_setup_golang

# 	go mod init || :
# 	go mod tidy
# }

build() {
	setup_golang
	go build -C cmd/ttyc -ldflags "-w -s"
	install -Dm700 -t "${OUTPUT_DIR}"/bin cmd/ttyc/ttyc

	# go build -C cmd/wistty -ldflags "-w -s"
	# install -Dm700 -t "${OUTPUT_DIR}"/bin cmd/wistty/wistty
}
