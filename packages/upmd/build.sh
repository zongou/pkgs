PKG_HOMEPAGE="https://github.com/rezigned/upmd"
PKG_DESCRIPTION="A post-modern modal text editor written in rust"
PKG_LICENSE="MPL-2.0"

PKG_VERSION="0.2.0"
# PKG_SRCURL=https://github.com/Watfaq/clash-rs/archive/refs/tags/v0.2.0.tar.gz
PKG_SRCURL=https://github.com/rezigned/upmd/archive/refs/tags/v0.2.0.tar.gz
PKG_BASENAME=${PKG}-${PKG_VERSION}
BUILD_PREFIX="${RUST_BUILD_DIR}"

build() {
    ls
    setup_rust
    patch -up1 < "${PKG_CONFIG_DIR}/clipboard.patch"
    cargo build --release --target "${CARGO_BUILD_TARGET}"
    install "target/${CARGO_BUILD_TARGET}/release/${PKG}" -D "${OUTPUT_DIR}/bin/${PKG}"
}
