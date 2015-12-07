all:
	xcodebuild -configuration Release
	cp -r build/Release/Rust.bblm Contents/"Language Modules"
	cd helper-tool; cargo build --release; cp target/release/impl-generator ../Contents/Resources/impl-generator

clean:
	rm -r build; cd helper-tool; cargo clean
