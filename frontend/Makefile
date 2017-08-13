all: js/elm.min.js

js/elm.min.js: js/elm.js
	closure-compiler --js $< --js_output_file $@

js/elm.js: FORCE
	elm-make src/Main.elm --output js/elm.js

FORCE:
