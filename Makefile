SRC_DIR = src
DIST_DIR = dist
ASSETS_DIR = assets


build: src lib tar


tar:
	tar -cvzf app.tar.gz $(DIST_DIR)/*

lib:
	cp $(ASSETS_DIR)/* $(DIST_DIR)/

src: clean build-js


build-js:
	elm-make $(SRC_DIR)/main.elm --output=$(DIST_DIR)/app.js

clean:
	-rm -rf $(DIST_DIR)
