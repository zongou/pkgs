setup_source() {
	BUILD_DIR=${BUILD_PREFIX}/android-sdk-tools
	git clone https://github.com/lzhiyong/android-sdk-tools "${BUILD_DIR}"
	cd "${BUILD_DIR}" || exit
}
