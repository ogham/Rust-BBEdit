extern crate hoedown;
use hoedown::{Markdown, Html, Render, Extension};
use hoedown::renderer::html::{self, HARD_WRAP};

use std::io::{self, BufRead};


fn main() {
    let extensions: Extension =
        hoedown::AUTOLINK |
        hoedown::FENCED_CODE |
        hoedown::FOOTNOTES |
        hoedown::NO_INTRA_EMPHASIS |
        hoedown::STRIKETHROUGH |
        hoedown::SUPERSCRIPT |
        hoedown::TABLES;

    let stdin = io::stdin();
    let mut buffer = String::new();
    let mut was_doc = false;
    let mut was_module_comment = false;

    let mut flags = html::Flags::all();
    flags.remove(HARD_WRAP);

    let print_markdown = |buf: &str, mod_comment: bool| {
        let doc = Markdown::new(buf.trim_right()).extensions(extensions);
        let mut html = Html::new(flags, 0);

        let classes = match mod_comment {
            true  => "docs module",
            false => "docs",
        };

        println!("<div class=\"{}\">{}</div>", classes, html.render(&doc).to_str().unwrap());
    };

    let print_code = |buf: &str| {
        println!("<pre class=\"code\">{}</pre>", buf.trim_right().replace("<", "&lt;").replace(">", "&gt;"));
    };

    for line in stdin.lock().lines() {
        let line = line.unwrap();

        let mut slice = &line[..];
        let mut is_doc = false;

        if let Some(first_char) = line.find(|c: char| !c.is_whitespace()) {
            let line = &line[first_char ..];
            if line.starts_with("//! ") || line.starts_with("/// ") {
                slice = &slice[4 + first_char ..];
                is_doc = true;
            }
            else if line.starts_with("//!") || line.starts_with("///") {
                slice = &slice[3 + first_char ..];
                is_doc = true;
            }

        }

        if !buffer.trim().is_empty() {
            if is_doc && !was_doc {
                print_code(&*buffer);
                buffer.clear();
            }
            else if !is_doc && was_doc {
                print_markdown(&*buffer, was_module_comment);
                buffer.clear();
            }
        }

        buffer.push_str(slice);
        buffer.push('\n');

        was_doc = is_doc;
        was_module_comment = line.starts_with("//!");
    }

    if !was_doc {
        print_code(&*buffer);
        buffer.clear();
    }
    else {
        print_markdown(&*buffer, false);
        buffer.clear();
    }
}
