all:
	xcodebuild -configuration Release
	cp -r build/Release/Rust.bblm Contents/"Language Modules"

clean:
	rm -r build