PKG_HOMEPAGE=https://github.com/sigoden/aichat
PKG_DESCRIPTION="A powerful chatgpt cli"
PKG_LICENSE="Apache-2.0,MIT"
PKG_LICENSE_FILE="LICENSE-APACHE,LICENSE-MIT"
PKG_VERSION="0.27.0"
PKG_SRCURL=https://github.com/sigoden/aichat/archive/v$PKG_VERSION.tar.gz
PKG_AUTO_UPDATE=true
PKG_BUILD_IN_SRC=true

# # This package contains makefiles to run the tests. So, we need to override build steps.
# step_make() {
# 	setup_rust
# 	cargo build --jobs $PKG_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release
# }

# step_make_install() {
# 	install -Dm700 -t $PREFIX/bin target/${CARGO_TARGET_NAME}/release/aichat
# }

PKG_BASENAME=aichat-${PKG_VERSION}
BUILD_PREFIX="${RUST_BUILD_DIR}"

build() {
	setup_rust
	export RUSTFLAGS="-C target-feature=-crt-static"
	cargo build --target="${CARGO_BUILD_TARGET}" --release

	PKG_NAME=aichat
	install "target/${CARGO_BUILD_TARGET}/release/${PKG_NAME}" -D "${OUTPUT_DIR}/bin/${PKG_NAME}"
}
