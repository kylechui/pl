import gleeunit/should
import lexer
import token

pub fn can_lex_let_literal_test() {
  "let" |> lexer.lex |> should.equal([#(Ok(token.Let), 0)])
}

pub fn can_lex_function_literal_test() {
  "fn" |> lexer.lex |> should.equal([#(Ok(token.Function), 0)])
}

pub fn can_lex_equals_literal_test() {
  "=" |> lexer.lex |> should.equal([#(Ok(token.Equals), 0)])
}

pub fn can_lex_left_brace_literal_test() {
  "{" |> lexer.lex |> should.equal([#(Ok(token.LeftBrace), 0)])
}

pub fn can_lex_left_bracket_literal_test() {
  "[" |> lexer.lex |> should.equal([#(Ok(token.LeftBracket), 0)])
}

pub fn can_lex_left_parenthesis_literal_test() {
  "(" |> lexer.lex |> should.equal([#(Ok(token.LeftParenthesis), 0)])
}

pub fn can_lex_integer_literal_test() {
  "100" |> lexer.lex |> should.equal([#(Ok(token.Integer(num: 100)), 0)])
}

pub fn can_lex_negative_integer_literal_test() {
  "-100" |> lexer.lex |> should.equal([#(Ok(token.Integer(num: -100)), 0)])
}

// TODO: Correctly lex floats without trailing digits
// pub fn can_lex_float_literal_test() {
//   "100." |> lexer.lex |> should.equal([#(Ok(token.Float(num: 100.0)), 0)])
// }
//
// pub fn can_lex_negative_float_literal_test() {
//   "-100." |> lexer.lex |> should.equal([#(Ok(token.Float(num: -100.0)), 0)])
// }

pub fn can_lex_match_literal_test() {
  "match" |> lexer.lex |> should.equal([#(Ok(token.Match), 0)])
}

pub fn can_lex_plus_literal_test() {
  "+" |> lexer.lex |> should.equal([#(Ok(token.Plus), 0)])
}

pub fn can_lex_comma_literal_test() {
  "," |> lexer.lex |> should.equal([#(Ok(token.Comma), 0)])
}

pub fn can_lex_right_brace_literal_test() {
  "}" |> lexer.lex |> should.equal([#(Ok(token.RightBrace), 0)])
}

pub fn can_lex_right_bracket_literal_test() {
  "]" |> lexer.lex |> should.equal([#(Ok(token.RightBracket), 0)])
}

pub fn can_lex_right_parenthesis_literal_test() {
  ")" |> lexer.lex |> should.equal([#(Ok(token.RightParenthesis), 0)])
}

pub fn can_lex_pipe_literal_test() {
  "|" |> lexer.lex |> should.equal([#(Ok(token.Pipe), 0)])
}

pub fn can_lex_arrow_literal_test() {
  "->" |> lexer.lex |> should.equal([#(Ok(token.Arrow), 0)])
}

pub fn can_lex_string_literal_test() {
  "\"foobarbaz\""
  |> lexer.lex
  |> should.equal([#(Ok(token.String(str: "foobarbaz")), 0)])
}

pub fn can_lex_escaped_string_literal_test() {
  "\"escaped \\\"quote\\\" string\""
  |> lexer.lex
  |> should.equal([#(Ok(token.String(str: "escaped \"quote\" string")), 0)])
}

pub fn can_lex_public_literal_test() {
  "pub" |> lexer.lex |> should.equal([#(Ok(token.Public), 0)])
}

pub fn can_lex_identifier_literal_test() {
  "foobarbaz"
  |> lexer.lex
  |> should.equal([#(Ok(token.Identifier(name: "foobarbaz")), 0)])
}

pub fn can_lex_simple_function_test() {
  "pub fn main(argc, argv) {
  let x = match 3 {
    1 -> \"hi\"
    2 -> \"escaped \\\"quote\\\"\"
    _ -> something_else
  }
  x
}"
  |> lexer.lex
  |> should.equal([
    #(Ok(token.Public), 0),
    #(Ok(token.Function), 4),
    #(Ok(token.Identifier(name: "main")), 7),
    #(Ok(token.LeftParenthesis), 11),
    #(Ok(token.Identifier(name: "argc")), 12),
    #(Ok(token.Comma), 16),
    #(Ok(token.Identifier(name: "argv")), 18),
    #(Ok(token.RightParenthesis), 22),
    #(Ok(token.LeftBrace), 24),
    #(Ok(token.Let), 28),
    #(Ok(token.Identifier(name: "x")), 32),
    #(Ok(token.Equals), 34),
    #(Ok(token.Match), 36),
    #(Ok(token.Integer(num: 3)), 42),
    #(Ok(token.LeftBrace), 44),
    #(Ok(token.Integer(num: 1)), 50),
    #(Ok(token.Arrow), 52),
    #(Ok(token.String(str: "hi")), 55),
    #(Ok(token.Integer(num: 2)), 64),
    #(Ok(token.Arrow), 66),
    #(Ok(token.String(str: "escaped \"quote\"")), 69),
    #(Ok(token.Identifier(name: "_")), 93),
    #(Ok(token.Arrow), 95),
    #(Ok(token.Identifier(name: "something_else")), 98),
    #(Ok(token.RightBrace), 115),
    #(Ok(token.Identifier(name: "x")), 119),
    #(Ok(token.RightBrace), 121),
  ])
}
