import gleeunit/should
import lexer
import token

pub fn can_lex_let_literal_test() {
  "let" |> lexer.lex |> should.equal([Ok(token.Let)])
}

pub fn can_lex_function_literal_test() {
  "fn" |> lexer.lex |> should.equal([Ok(token.Function)])
}

pub fn can_lex_equals_literal_test() {
  "=" |> lexer.lex |> should.equal([Ok(token.Equals)])
}

pub fn can_lex_left_brace_literal_test() {
  "{" |> lexer.lex |> should.equal([Ok(token.LeftBrace)])
}

pub fn can_lex_left_bracket_literal_test() {
  "[" |> lexer.lex |> should.equal([Ok(token.LeftBracket)])
}

pub fn can_lex_left_parenthesis_literal_test() {
  "(" |> lexer.lex |> should.equal([Ok(token.LeftParenthesis)])
}

pub fn can_lex_integer_literal_test() {
  "100" |> lexer.lex |> should.equal([Ok(token.Integer(num: 100))])
}

pub fn can_lex_negative_integer_literal_test() {
  "-100" |> lexer.lex |> should.equal([Ok(token.Integer(num: -100))])
}

pub fn can_lex_match_literal_test() {
  "match" |> lexer.lex |> should.equal([Ok(token.Match)])
}

pub fn can_lex_plus_literal_test() {
  "+" |> lexer.lex |> should.equal([Ok(token.Plus)])
}

pub fn can_lex_comma_literal_test() {
  "," |> lexer.lex |> should.equal([Ok(token.Comma)])
}

pub fn can_lex_right_brace_literal_test() {
  "}" |> lexer.lex |> should.equal([Ok(token.RightBrace)])
}

pub fn can_lex_right_bracket_literal_test() {
  "]" |> lexer.lex |> should.equal([Ok(token.RightBracket)])
}

pub fn can_lex_right_parenthesis_literal_test() {
  ")" |> lexer.lex |> should.equal([Ok(token.RightParenthesis)])
}

pub fn can_lex_pipe_literal_test() {
  "|" |> lexer.lex |> should.equal([Ok(token.Pipe)])
}

pub fn can_lex_arrow_literal_test() {
  "->" |> lexer.lex |> should.equal([Ok(token.Arrow)])
}

pub fn can_lex_string_literal_test() {
  "\"foobarbaz\""
  |> lexer.lex
  |> should.equal([Ok(token.String(str: "foobarbaz"))])
}

pub fn can_lex_escaped_string_literal_test() {
  "\"escaped \\\"quote\\\" string\""
  |> lexer.lex
  |> should.equal([Ok(token.String(str: "escaped \"quote\" string"))])
}

pub fn can_lex_public_literal_test() {
  "pub" |> lexer.lex |> should.equal([Ok(token.Public)])
}

pub fn can_lex_identifier_literal_test() {
  "foobarbaz"
  |> lexer.lex
  |> should.equal([Ok(token.Identifier(name: "foobarbaz"))])
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
    Ok(token.Public),
    Ok(token.Function),
    Ok(token.Identifier(name: "main")),
    Ok(token.LeftParenthesis),
    Ok(token.Identifier(name: "argc")),
    Ok(token.Comma),
    Ok(token.Identifier(name: "argv")),
    Ok(token.RightParenthesis),
    Ok(token.LeftBrace),
    Ok(token.Let),
    Ok(token.Identifier(name: "x")),
    Ok(token.Equals),
    Ok(token.Match),
    Ok(token.Integer(num: 3)),
    Ok(token.LeftBrace),
    Ok(token.Integer(num: 1)),
    Ok(token.Arrow),
    Ok(token.String(str: "hi")),
    Ok(token.Integer(num: 2)),
    Ok(token.Arrow),
    Ok(token.String(str: "escaped \"quote\"")),
    Ok(token.Identifier(name: "_")),
    Ok(token.Arrow),
    Ok(token.Identifier(name: "something_else")),
    Ok(token.RightBrace),
    Ok(token.Identifier(name: "x")),
    Ok(token.RightBrace),
  ])
}
