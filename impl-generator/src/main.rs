extern crate regex;
use regex::Regex;

use std::fmt;
use std::io::{self, BufRead};
use std::process;
use std::string::ToString;


fn main() {
    let regex = Regex::new(r##"(?x)
        ^ impl
        (?: < [^>]+ >)? \s+

        ([A-Za-z0-9_:]+)
        (< [^>]+ >)? \s+

        for \s+

        ([A-Za-z0-9_:]+)
        (< [^>]+ >)? \s*

        \{? $
    "##).unwrap();

    let stdin = io::stdin();
    let line = stdin.lock().lines().next().unwrap_or_else(||fail("Failed to read line")).unwrap();

    let caps = regex.captures(&*line).unwrap_or_else(||fail("Invalid impl line"));
    let trait_name = caps.at(1).unwrap_or("");
    let trait_args = caps.at(2).unwrap_or("");
    let type_name  = caps.at(3).unwrap_or("");
    let type_args  = caps.at(4).unwrap_or("");

    if let Some(components) = get_components(trait_name) {
        println!("impl{} {}{} for {}{} {{", type_args, trait_name,trait_args, type_name,type_args);

        let mut printed_anything = false;
        for component in components.iter() {
            if printed_anything == false {
                printed_anything = true;
            }
            else {
                println!("");
            }

            let text = component.to_string();

            if text.contains("PARAM") && trait_args.is_empty() {
                fail(&*format!("Trait {} needs a generic argument", trait_name));
            }

            let rhs = if trait_args.is_empty() { type_name } else { &trait_args[1 .. trait_args.len() - 1] };

            let text = text.replace("SELF",  &*format!("{}{}", type_name, type_args))
                           .replace("PARAM", rhs)
                           .replace("RHS",   rhs);

            println!("{}", text);
        }

        println!("}}");
    }
    else {
        fail(&*format!("Unknown trait name: {}", trait_name));
    }
}

#[derive(Copy, Clone)]
enum Component<'a> {
    AssocType(&'a str),

    Function {
        name: &'a str,
        input: &'a str,
        output: Option<&'a str>,
        params: Option<&'a str>,
    },
}

impl<'a> fmt::Display for Component<'a> {
    fn fmt(&self, f: &mut fmt::Formatter) -> Result<(), fmt::Error> {
        match *self {
            Component::AssocType(name) => {
                write!(f, "    type {} = <#...#>;", name)
            },
            Component::Function { name, input, output, params } => {
                try!(write!(f, "    fn {}", name));

                if let Some(params) = params {
                    try!(write!(f, "<{}>", params));
                }

                try!(write!(f, "({})", input));

                if let Some(output) = output {
                    try!(write!(f, " -> {}", output));
                }

                write!(f, " {{\n        <#...#>\n    }}")
            },
        }
	}
}

fn get_components(trait_name: &str) -> Option<Vec<Component<'static>>> {
    use self::Component::*;

    let bits = match trait_name {

        // -- std::borrow --

        "Borrow" => vec![
            Function {
                name: "borrow",
                input: "&self",
                output: Some("&PARAM"),
                params: None,
            }
        ],

        "BorrowMut" => vec![
            Function {
                name: "borrow_mut",
                input: "&mut self",
                output: Some("&mut PARAM"),
                params: None,
            }
        ],

        "IntoCow" => vec![
            Function {
                name: "into_cow",
                input: "self",
                output: Some("Cow<PARAM>"),
                params: None,
            }
        ],

        "ToOwned" => vec![
            AssocType("Owned"),
            Function {
                name: "to_owned",
                input: "&self",
                output: Some("Self::Owned"),
                params: None,
            }
        ],

        // -- std::clone --

        "Clone" => vec![
            Function {
                name: "clone",
                input: "&self",
                output: Some("SELF"),
                params: None,
            }
        ],

        // -- std::cmp --

        "PartialEq" => vec![
            Function {
                name: "eq",
                input: "&self, other: &RHS",
                output: Some("bool"),
                params: None,
            }
        ],

        "PartialOrd" => vec![
            Function {
                name: "partial_cmp",
                input: "&self, other: &RHS",
                output: Some("Option<Ordering>"),
                params: None,
            }
        ],

        // -- std::convert --

        "AsMut" => vec![
            Function {
                name: "as_mut",
                input: "&mut self",
                output: Some("&mut PARAM"),
                params: None,
            }
        ],

        "AsRef" => vec![
            Function {
                name: "as_ref",
                input: "&self",
                output: Some("&PARAM"),
                params: None,
            }
        ],

        "From" => vec![
            Function {
                name: "from",
                input: "PARAM",
                output: Some("SELF"),
                params: None,
            }
        ],

        "Into" => vec![
            Function {
                name: "into",
                input: "self",
                output: Some("PARAM"),
                params: None,
            }
        ],

        // -- std::default --

        "Default" => vec![
            Function {
                name: "default",
                input: "",
                output: Some("SELF"),
                params: None,
            }
        ],

        // -- std::error --

        "Error" => vec![
            Function {
                name: "description",
                input: "&self",
                output: Some("&str"),
                params: None,
            },

            Function {
                name: "cause",
                input: "&self",
                output: Some("Option<&Error>"),
                params: None,
            }
        ],

        // -- std::fmt --

        "Binary" | "Debug" | "Display" | "LowerExp" | "LowerHex" | "Octal" |
            "Pointer" | "UpperExp" | "UpperHex"
                => format(),

        // -- std::hash --

        "Hash" => vec![
            Function {
                name: "hash",
                input: "&self, state: &mut H",
                output: None,
                params: Some("H: Hasher"),
            }
        ],

        // -- std::iter --

        "Iterator" => vec![
            AssocType("Item"),
            Function {
                name: "next",
                input: "&mut self",
                output: Some("Option<Self::Item>"),
                params: None,
            },
        ],

        // -- std::ops --

        "Add"    => maths("add"),
        "BitAnd" => maths("bitand"),
        "BitOr"  => maths("bitor"),
        "BitXor" => maths("bitxor"),
        "Div"    => maths("div"),
        "Mul"    => maths("mul"),
        "Rem"    => maths("rem"),
        "Shl"    => maths("shl"),
        "Shr"    => maths("shr"),
        "Sub"    => maths("sub"),

        "Not" => vec![
            AssocType("Output"),
            Function {
                name: "not",
                input: "self",
                output: Some("Self::Output"),
                params: None,
            },
        ],

        "Neg" => vec![
            AssocType("Output"),
            Function {
                name: "neg",
                input: "self",
                output: Some("Self::Output"),
                params: None,
            },
        ],

        "Deref" => vec![
            AssocType("Target"),
            Function {
                name: "deref",
                input: "&'a self",
                output: Some("&'a Self::Target"),
                params: Some("'a"),
            },
        ],

        "DerefMut" => vec![
            AssocType("Target"),
            Function {
                name: "deref_mut",
                input: "&'a mut self",
                output: Some("&'a mut Self::Target"),
                params: Some("'a"),
            },
        ],

        "Index" => vec![
            AssocType("Output"),
            Function {
                name: "index",
                input: "&'a self, index: PARAM",
                output: Some("&'a Self::Output"),
                params: Some("'a"),
            },
        ],

        "IndexMut" => vec![
            AssocType("Output"),
            Function {
                name: "index",
                input: "&'a mut self, index: PARAM",
                output: Some("&'a mut Self::Output"),
                params: Some("'a"),
            },
        ],

        // -- std::str --

        "FromStr" => vec![
            AssocType("Err"),
            Function {
                name: "from_str",
                input: "s: &str",
                output: Some("Result<SELF, Self::Err>"),
                params: None,
            },
        ],


        _ => return None,
    };

    Some(bits)
}

fn maths(name: &'static str) -> Vec<Component<'static>> {
    vec![
        Component::AssocType("Output"),
        Component::Function {
            name: name,
            input: "self, rhs: RHS",
            output: Some("Self::Output"),
            params: None,
        },
    ]
}

fn format() -> Vec<Component<'static>> {
    vec![
        Component::Function {
            name: "fmt",
            input: "&self, &mut fmt::Formatter",
            output: Some("Result<(), fmt::Error>"),
            params: None,
        }
    ]
}

fn fail(message: &str) -> ! {
    println!("{}", message);
    process::exit(1);
}

