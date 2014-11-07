BBEdit language module for Rust
===============================

This is a BBEdit 11 Language Module for [Rust](http://www.rust-lang.org). It provides the following features:

- Complete syntax highlighting
    - Special support for lifetimes, attributes, and identifiers
    - Customisable colours using the [BBEdit 11 colour thing](http://barebones.com/products/bbedit/bbedit11.html)
- Language features
    - Go to start of/end of/previous/next function
    - Go to named symbol
    - Indexed function menu

By default, it highlights anything beginning with a capital letter in a certain colour. To turn this off, just change the Identifier colour to be the same as the default text colour in Preferences.

### Installation

The simplest way is to just download the package and put it in this folder:

    ~/Application Support/BBEdit/Language Modules

Then restart your BBEdit and it should be picked up.

### Compilation

To compile your own version, you'll need Xcode. The default schema outputs a `.bblm`. You'll also need the BBEdit SDK. The project assumes it's mounted under `/Volumes/BBEdit SDK`.

