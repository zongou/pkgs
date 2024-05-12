PKG_HOMEPAGE="https://helix-editor.com/"
PKG_DESCRIPTION="A post-modern modal text editor written in rust"
PKG_LICENSE="MPL-2.0"
PKG_MAINTAINER="Aditya Alok <alok@termux.org>"

PKG_VERSION="24.03"
PKG_NAME=helix
PKG_BASENAME=${PKG_NAME}-${PKG_VERSION}
PKG_EXTNAME=.tar.gz
PKG_SRCURL=https://github.com/helix-editor/helix/archive/refs/tags/${PKG_VERSION}.tar.gz
PKG_GIT_BRANCH="${PKG_VERSION}"
PKG_SUGGESTS="helix-grammars"
PKG_BUILD_IN_SRC=true
PKG_AUTO_UPDATE=true
PKG_RM_AFTER_INSTALL="
opt/helix/runtime/grammars/sources/
"

# step_make_install() {
# 	setup_rust

# 	cargo build --jobs "${MAKE_PROCESSES}" --target "${CARGO_TARGET_NAME}" --release

# 	local datadir="${PREFIX}/opt/${PKG_NAME}"
# 	mkdir -p "${datadir}"

# 	cat >"${PREFIX}/bin/hx" <<-EOF
# 		#!${PREFIX}/bin/sh
# 		HELIX_RUNTIME=${datadir}/runtime exec ${datadir}/hx "\$@"
# 	EOF
# 	chmod 0700 "${PREFIX}/bin/hx"

# 	install -Dm700 target/"${CARGO_TARGET_NAME}"/release/hx "${datadir}/hx"

# 	cp -r ./runtime "${datadir}"
# 	find "${datadir}"/runtime/grammars -type f -name "*.so" -exec chmod 0700 {} \;
# }

build() {
	setup_rust
	export RUSTFLAGS="-C link-arg=-s -C opt-level=s -C lto=true"
	cargo build --release
	install "target/${CARGO_BUILD_TARGET}/release/${PKG_NAME}" -D "${OUTPUT_DIR}/bin/${PKG_NAME}"
}
