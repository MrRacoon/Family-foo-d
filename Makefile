NAME        = friendlyFoo
DIST_DIR    = $(NAME)

CLIENT_DIR  = client
TARGET      = $(CLIENT_DIR)/Main.elm

SERVER_DIR  = server
SERVER_FILE = $(SERVER_DIR)/index.js

ASSETS_DIR  = assets
INDEX       = $(DIST_DIR)/index.html

PKG_DIR     = pkg
TAR_FILE    = $(PKG_DIR)/$(NAME).tar.bz
MD5_FILE    = $(PKG_DIR)/$(NAME).md5

################################################################################

all: build

package: build tar

tar:
	-rm -rf $(PKG_DIR)
	mkdir -p $(PKG_DIR)
	tar -cvjf $(TAR_FILE) $(DIST_DIR)
	md5sum $(TAR_FILE) >> $(MD5_FILE)

dev-server:
	(cd $(DIST_DIR); node index.js; cd -)

build: src-client src-server src-lib

src-server:
	cp server/index.js $(DIST_DIR)/index.js

src-lib:
	cp $(ASSETS_DIR)/* $(DIST_DIR)/

src-client: clean build-js

clean:
	-rm -rf $(DIST_DIR)
	-rm -rf $(PKG_DIR)

build-js:
	elm-make $(TARGET) --output=$(DIST_DIR)/app.js

dev: build chrome-dist

chrome-dist:
	chromium-browser $(INDEX)
