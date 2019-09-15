website:
	flutter build web
	rm -rf docs/ || true
	cp -r build/web docs/
