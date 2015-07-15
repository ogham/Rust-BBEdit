all:
	xcodebuild -configuration Release
	cp -r build/Release/Rust.bblm Contents/"Language Modules"
	cd impl-generator; cargo build --release; cp target/release/impl-generator ../Contents/Resources/impl-generator-bin

clean:
	rm -r build