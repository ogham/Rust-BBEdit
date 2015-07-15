BBEdit Package for Rust
=======================

!["A screenshot of the language module"](https://raw.githubusercontent.com/ogham/Rust.bblm/master/screenshot.png)

This is a BBEdit 11 Package for [Rust](http://www.rust-lang.org). It provides the following features:

- Complete syntax highlighting
    - Special support for lifetimes, attributes, and identifiers
    - Customisable colours using the [BBEdit 11 colour editor](http://barebones.com/products/bbedit/bbedit11.html)
- Language features
    - Go to start of/end of/previous/next function
    - Go to named symbol
    - Indexed function menu
    - Code folding
- Code helpers
    - Clippings for common code patterns
    - Autogeneration for standard library trait impls

By default, it highlights anything beginning with a capital letter in a certain colour. To turn this off, just change the Identifier colour to be the same as the default text colour in Preferences.

### Installation

To install this package, simply clone the repo into BBEdit's Packages folder:

```bash
$ git clone https://github.com/ogham/Rust-BBEdit.git ~/Library/Application\ Support/BBEdit/Packages/Rust.bbpackage
```

Then restart your BBEdit and it should be picked up. It's necessary for the filename to end in `.bbpackage`.

### Compilation

To compile your own version, you'll need Xcode. The default schema outputs a `.bblm`. You'll also need the BBEdit SDK. The project assumes it's mounted under `/Volumes/BBEdit SDK`. There's a `Makefile` that runs the build commands.
