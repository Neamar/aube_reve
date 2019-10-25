website:
	flutter build web
	rm -rf docs/ || true
	cp -r build/web docs/
	cp web/small.html docs/
	cp -r web/icons docs/
	echo "aubereve.neamar.fr" > docs/CNAME
