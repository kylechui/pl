import combinator
import gleam/io
import gleeunit
import gleeunit/should
import lexer
import parser
import token

pub fn main() {
  gleeunit.main()
}

pub fn should_fail_test() {
  "300" |> lexer.lex |> combinator.literal(token.Let) |> should.be_error
}
