NAME = friendlyFoo
SRC_DIR = src
MAIN_FILE = Main.elm
TARGET = $(SRC_DIR)/$(MAIN_FILE)
ASSETS_DIR = assets
DIST_DIR = friendlyFoo
INDEX = $(DIST_DIR)/index.html

PKG_DIR = pkg
TAR_FILE = $(PKG_DIR)/$(NAME).tar.bz
MD5_FILE = $(PKG_DIR)/$(NAME).md5

all: build

package: build tar

tar:
	-rm -rf $(PKG_DIR)
	mkdir -p $(PKG_DIR)
	tar -cvjf $(TAR_FILE) $(DIST_DIR)
	md5sum $(TAR_FILE) >> $(MD5_FILE)

build: src lib

lib:
	cp $(ASSETS_DIR)/* $(DIST_DIR)/

src: clean build-js

clean:
	-rm -rf $(DIST_DIR)
	-rm -rf $(PKG_DIR)

build-js:
	elm-make $(TARGET) --output=$(DIST_DIR)/app.js

dev: build chrome-dist

chrome-dist:
	chromium-browser $(INDEX)
