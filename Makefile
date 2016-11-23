NAME        = friendlyFoo
DIST_DIR    = $(NAME)
INDEX       = $(DIST_DIR)/index.html

CLIENT_DIR  = client
TARGET      = $(CLIENT_DIR)/Main.elm

SERVER_DIR  = server
SERVER_FILE = $(SERVER_DIR)/index.js

ASSETS_DIR  = assets

PKG_DIR     = pkg
TAR_FILE    = $(PKG_DIR)/$(NAME).tar.bz
MD5_FILE    = $(PKG_DIR)/$(NAME).md5

NODE_MODULES = node_modules
ELM_STUFF    = elm-stuff

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
	cp -R server/* $(DIST_DIR)/

src-lib:
	cp $(ASSETS_DIR)/* $(DIST_DIR)/

src-client: clean build-js

clean:
	-rm -rf $(DIST_DIR)
	-rm -rf $(PKG_DIR)
	-rm -rf $(NODE_MODULES)
	-rm -rf $(ELM_STUFF)

build-js: build-deps
	elm-make $(TARGET) --output=$(DIST_DIR)/app.js

build-deps:
	npm install
	elm-make --yes

dev: build client-dist server-dist

client-dist:
	firefox $(INDEX)

server-dist:
	node $(SERVER_FILE)

