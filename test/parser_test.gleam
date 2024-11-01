import ast
import combinator.{Value}
import gleam/io
import gleeunit
import gleeunit/should
import lexer
import parser
import token

pub fn can_parse_string_test() {
  [token.String(str: "foobar")]
  |> parser.parse_string()
  |> should.equal(Ok(Value(value: "foobar", input: [])))
}

pub fn can_parse_integer_test() {
  [token.Integer(num: 999)]
  |> parser.parse_int()
  |> should.equal(Ok(Value(value: 999, input: [])))
}

pub fn can_parse_identifier_test() {
  [token.Identifier(name: "foobar")]
  |> parser.parse_identifier()
  |> should.equal(Ok(Value(value: "foobar", input: [])))
}

pub fn can_parse_let_test() {
  [
    token.Let,
    token.Identifier(name: "foobar"),
    token.Equals,
    token.String(str: "hi"),
    token.Integer(num: 1729),
  ]
  |> parser.parse_let()
  |> should.equal(
    Ok(
      Value(
        value: ast.Let(
          lhs: "foobar",
          rhs: ast.String(str: "hi"),
          body: ast.Integer(num: 1729),
        ),
        input: [],
      ),
    ),
  )
}

pub fn can_parse_nested_let_test() {
  [
    token.Let,
    token.Identifier(name: "foobar"),
    token.Equals,
    token.String(str: "hi"),
    token.Let,
    token.Identifier(name: "baz"),
    token.Equals,
    token.Identifier(name: "qux"),
    token.Integer(num: 1729),
  ]
  |> parser.parse_let()
  |> should.equal(
    Ok(
      Value(
        value: ast.Let(
          lhs: "foobar",
          rhs: ast.String(str: "hi"),
          body: ast.Let(
            lhs: "baz",
            rhs: ast.Identifier(name: "qux"),
            body: ast.Integer(num: 1729),
          ),
        ),
        input: [],
      ),
    ),
  )
}
