import gleeunit/should
import lexer
import token

pub fn can_lex_let_literal_test() {
  "let" |> lexer.lex |> should.equal([token.Let])
}

pub fn can_lex_function_literal_test() {
  "fn" |> lexer.lex |> should.equal([token.Function])
}

pub fn can_lex_equals_literal_test() {
  "=" |> lexer.lex |> should.equal([token.Equals])
}

pub fn can_lex_left_brace_literal_test() {
  "{" |> lexer.lex |> should.equal([token.LeftBrace])
}

pub fn can_lex_left_bracket_literal_test() {
  "[" |> lexer.lex |> should.equal([token.LeftBracket])
}

pub fn can_lex_left_parenthesis_literal_test() {
  "(" |> lexer.lex |> should.equal([token.LeftParenthesis])
}

pub fn can_lex_integer_literal_test() {
  "100" |> lexer.lex |> should.equal([token.Integer(num: 100)])
}

pub fn can_lex_match_literal_test() {
  "match" |> lexer.lex |> should.equal([token.Match])
}

pub fn can_lex_plus_literal_test() {
  "+" |> lexer.lex |> should.equal([token.Plus])
}

pub fn can_lex_comma_literal_test() {
  "," |> lexer.lex |> should.equal([token.Comma])
}

pub fn can_lex_right_brace_literal_test() {
  "}" |> lexer.lex |> should.equal([token.RightBrace])
}

pub fn can_lex_right_bracket_literal_test() {
  "]" |> lexer.lex |> should.equal([token.RightBracket])
}

pub fn can_lex_right_parenthesis_literal_test() {
  ")" |> lexer.lex |> should.equal([token.RightParenthesis])
}

pub fn can_lex_pipe_literal_test() {
  "|" |> lexer.lex |> should.equal([token.Pipe])
}

pub fn can_lex_arrow_literal_test() {
  "->" |> lexer.lex |> should.equal([token.Arrow])
}

pub fn can_lex_string_literal_test() {
  "\"foobarbaz\"" |> lexer.lex |> should.equal([token.String(str: "foobarbaz")])
}

pub fn can_lex_public_literal_test() {
  "pub" |> lexer.lex |> should.equal([token.Public])
}

pub fn can_lex_identifier_literal_test() {
  "foobarbaz"
  |> lexer.lex
  |> should.equal([token.Identifier(name: "foobarbaz")])
}
