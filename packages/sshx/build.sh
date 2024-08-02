## https://docs.helix-editor.com/building-from-source.html

PKG_HOMEPAGE="https://helix-editor.com/"
PKG_DESCRIPTION="Fast, collaborative live terminal sharing over the web"
PKG_LICENSE="MIT"

PKG_VERSION="0.2.4"
PKG_SRCURL=https://kkgithub.com/ekzhang/sshx/archive/refs/tags/v${PKG_VERSION}.tar.gz

PKG_BASENAME=sshx-${PKG_VERSION}
BUILD_PREFIX="${SCRIPT_DIR}/build/rust"

build() {
	PKG_NAME=sshx

	setup_rust
	# export RUSTFLAGS="-C link-arg=-s -C opt-level=s -C lto=true"

	## If you are using the musl-libc standard library instead of glibc
	## the following environment variable must be set during the build
	## to ensure tree-sitter grammars can be loaded correctly:
	export RUSTFLAGS="-C target-feature=-crt-static"

	## If you do not want to fetch or build grammars, set an environment variable
	# export HELIX_DISABLE_AUTO_GRAMMAR_BUILD=

	cargo build --target="${CARGO_BUILD_TARGET}" --release

	install "target/${CARGO_BUILD_TARGET}/release/${PKG_NAME}" -D "${OUTPUT_DIR}/bin/${PKG_NAME}"
}
