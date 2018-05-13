bower install
cd ../lib/
coffee -c *.coffee
bash run.sh
cd ..
webpack lib/calling.js dist/housing-pano.js
cd dist/
uglifyjs housing-pano.js --source-map housing-pano.js.map
uglifyjs --compress --mangle -- housing-pano.js > housing-pano.min.js
cd ..
open http://localhost:8000/test/
python -m SimpleHTTPServer
