PKG_HOMEPAGE=https://github.com/ollama/ollama
PKG_DESCRIPTION="Get up and running with Llama 3, Mistral, Gemma 2, and other large language models."
PKG_LICENSE="MIT"
PKG_VERSION="0.2.1"
PKG_SRCURL=https://github.com/ollama/ollama/archive/refs/tags/v${PKG_VERSION}.tar.gz

PKG_BASENAME=ollama-${PKG_VERSION}
BUILD_PREFIX="${GO_BUILD_DIR}"

# configure() {
# 	patch -u < "${PKG_CONFIG_DIR}/android.patch"
# }

build() {
	setup_golang
	go build -ldflags='-w -s'
	install -Dt "${OUTPUT_DIR}/bin" ollama
	file ollama
}
