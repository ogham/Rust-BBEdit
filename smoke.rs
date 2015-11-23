// Keywords
// --------

  abstract, alignof, as, become, box, break, const, continue, crate, do, else, enum,
  extern, false, final, fn, for, if, impl, in, let, loop, macro, match, mod, move, mut,
  offsetof, override, priv, pub, pure, ref, return, sizeof, static, self, struct, super,
  true, trait, type, typeof, unsafe, unsized, use, virtual, where, while, yield.

// Types
// -----

  - ()
  - bool, char, str
  - u8, u16, u32, u64
  - i8, i16, i32, i64
  - f32, f64
  - usize, isize

  - int, uint    // these are no longer valid!

// Comments
// --------

  // This is a comment
  /* So is this */

  /// This is a doc comment
  /** So is this */

// Characters and Lifetimes
// ------------------------

  'a'        // a character
  'a         // a lifetime
  'static    // also a lifetime
  b'a'       // a byte

  ' '        // this is also a character (space)
  '\t'       // characters can be escaped
  '\''       // including the quote character itself!

  "geese"          // a string
  r##"geese"##     // a raw string. This part should not be highlighted!
  b"geese"         // a byte string
  br##"geese"##    // a raw byte string. This part should still not be highlighted

  "there's a \" in this string"  // be sure to handle escapes
  "\"geese\""                    // including at the edges

  r##"there's a " in this string"##  // the string shouldn't end until ##
  r##"there's a # in this string"##  // even if there's a # in the middle

  // " // in case the above failed :)

// Decimal Numbers
// ---------------

  7, 12, 1048576    // are all numbers
  1_000_000         // is a number with underscore separators
  _, _1000, 1000_   // beware of sole/leading/trailing underscores

// Hex Numbers
// -----------

  0xff              // hex numbers start with 0x
  0xFF              // and can be in lowercase or uppercase
  0x0123_4567       // and can have separators

// Octal Numbers
// -------------

  0o77              // octal numbers start with 0o
  0o12345678909     // and should finish after an 8 or 9

// Binary Numbers
// --------------

  0b0000_1111       // binary numbers start with 0b
  0b01234311        // and should finish after a 2 or higher

// Floating-Point Numbers
// ----------------------

  6.022E-23         // floating point notation
  5.974e24          // lowercase e
  7.348e+22         // uppercase E and plus

   .1234            // no leading zero (invalid)

  let tuple = ((8, 4), 48);
  tuple.0
  tuple.0.0         // tuple indexing (not really numbers)

// Numeric Suffixes
// ----------------

  123i32,  123u32   // numbers can have literals
  123_u32, 0xff_u8
  0o70_i16, 0b1111_1111_1001_0000_i32
  0usize, 7isize

  123.0f64
  0.1f64
  0.1f32
  12E+99_f64
  0us, 7is  // Invalid!
  2.f64     // Also invalid!

// Attributes
// ----------

  #[attribute]
  #[derive(This, That, Other)]
  #![top_level_attribute]
  #not_an_attribute

  #[macro_use] use this_is_not_an_attribute;

  #[unfinished_attribute                      // not a comment
  and this should be back to regular code.    // back to comments again

  #[unfinished_attribute="but look \          // not a comment
                          a string!"]         // back to comments again

// Macros
// ------

  macro_rules! parse {
      ($thing: expr) => { $thing };
  }

// `use` statements
// ----------------

use flux;
use flux::capacitor;
use flux::capacitor::Component::*;
use flux::capacitor::Component::{ImpurePalladium, ThinkingAluminium, TimeyWimeyDevice};
use flux::capacitor as cap;
use super;
use self;
