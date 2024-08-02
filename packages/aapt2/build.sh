# install_deps() {
# 	sudo apt-get install \
# 		git tar \
# 		ninja-build \
# 		autogen \
# 		autoconf \
# 		automake \
# 		libtool \
# 		build-essential \
# 		cmake m4 \
# 		-y || exit 1
# }

setup_protoc() {
	tools_path=$PWD/tools
	mkdir -p "$tools_path" || exit 1
	cd src/third_party/protobuf/cmake || exit 1
	mkdir -p build && cd build
	cmake -Dprotobuf_BUILD_TESTS=OFF ..
	make -j$(nproc)
	cp $(find . -name protoc-*) "$tools_path" || exit 1
	echo "PROTOC VERSION: $($(find "$tools_path" -name protoc-*) --version)"
	PROTOC=$(find "$tools_path" -name protoc-*)
	cd "${BUILD_PREFIX}/aapt2" || exit
}

setup_source() {
	if ! test -d "${BUILD_PREFIX}/aapt2"; then
		git clone https://kkgithub.com/zongou/aapt2 "${BUILD_PREFIX}/aapt2"
	fi
	cd "${BUILD_PREFIX}/aapt2" || exit
	sed -i "s^https://android.googlesource.com/platform^https://mirrors.ustc.edu.cn/aosp/platform^g" .gitmodules
	# ls
	# cat .gitmodules
	git submodule update --init --recursive
}

configure() {
	CC=cc CXX=c++ setup_protoc

	ABI=aarch64-linux
	API=24

	case $ANDROID_ABI in
	arm64-* | aarch64-*)
		ARCH=aarch64
		TARGET_ABI=arm64-v8a
		;;
	arm-*)
		ARCH=arm
		TARGET_ABI=armeabi-v7a
		;;
	x64-* | x86_64-*)
		ARCH=x86_64
		TARGET_ABI=x86_64
		;;
	x86-* | i686-*)
		ARCH=i686
		TARGET_ABI=x86
		;;
	*)
		msg "Invalid arch: $ABI!"
		exit 1
		;;
	esac

	msg "Configuring"
	cd ${BUILD_PREFIX}/aapt2
	rm -rf build && mkdir -p build

	git reset --hard
	patch -up1 <${PKG_CONFIG_DIR}/build.patch

	cmake -GNinja -B build \
		-DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake \
		-DANDROID_ABI=${TARGET_ABI} \
		-DANDROID_NATIVE_API_LEVEL=$API \
		-DANDROID_PLATFORM="android-$API" \
		-DCMAKE_SYSTEM_NAME="Android" \
		-DCMAKE_BUILD_TYPE="Release" \
		-DANDROID_STL="c++_static" \
		-DPROTOC_PATH="${PROTOC}" \
		-DCMAKE_EXE_LINKER_FLAGS="-static"
}

build() {
	ninja -C build -j"${JOBS}"

	"${STRIP}" build/bin/aapt2 -o "${OUTPUT_DIR}/bin/aapt2"
	"${STRIP}" build/bin/zipalign -o "${OUTPUT_DIR}/bin/zipalign"
}
