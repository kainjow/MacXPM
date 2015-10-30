BUILD_PATH := $(shell pwd)/magickbuild
SOURCE_FILENAME := ImageMagick.tar.gz
SOURCE_URL := http://www.imagemagick.org/download/$(SOURCE_FILENAME)
SOURCE_DIR := ImageMagick

magick_download:
	curl -O $(SOURCE_URL)
	mkdir -p $(SOURCE_DIR)
	tar -xzvf $(SOURCE_FILENAME) -C $(SOURCE_DIR) --strip-components=1

magick_build:
	mkdir -p $(BUILD_PATH)
	cd $(SOURCE_DIR) && \
		./configure --prefix=$(BUILD_PATH) \
			--disable-shared --disable-docs --disable-installed \
			--without-modules --without-perl --without-bzlib && \
		make && \
		make install

magick: magick_download magick_build
