PKG_HOMEPAGE=https://www.gnu.org/software/make/
PKG_DESCRIPTION="Tool to control the generation of non-source files from source files"
PKG_LICENSE="GPL-3.0"

PKG_VERSION="main"
PKG_BASENAME=prootie-${PKG_VERSION}
PKG_EXTNAME=.tar.gz
PKG_SRCURL="https://github.com/zongou/prootie/archive/refs/heads/main.tar.gz"

configure() {
ls
}

# build() {
# 	if command -v make >/dev/null; then
# 		make -j"${JOBS}" install
# 	else
# 		./build.sh
# 		mkdir -p "${OUTPUT_DIR}/bin"
# 		install make "${OUTPUT_DIR}/bin/make"
# 	fi
# }

# check() {
# 	test -f "${OUTPUT_DIR}/bin/make"
# }
