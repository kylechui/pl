import ast.{type Node}
import combinator.{Value}
import gleam/list
import gleam/option
import gleam/pair
import gleam/string
import token.{type Token}

pub type ParserValue(output_type) =
  combinator.Value(List(Token), output_type)

pub type ParserError {
  MissingToken(expected: Token)
  UnexpectedToken(expected: Token, got: Token)
  NoMatchingParsers(tokens: List(Token))
}

pub type Parser(value) =
  fn(List(Token)) -> Result(ParserValue(value), ParserError)

pub fn show_error(parser_error: ParserError) -> String {
  case parser_error {
    MissingToken(expected:) ->
      "Token stream terminated unexpectedly; expected: "
      <> token.to_string(expected)
    NoMatchingParsers(tokens:) ->
      "No matching parsers for token stream: "
      <> {
        tokens
        |> list.take(5)
        |> list.map(token.to_string)
        |> string.join(with: ", ")
      }
    UnexpectedToken(expected:, got:) ->
      "Unexpected token found. Expected: "
      <> token.to_string(expected)
      <> " but got: "
      <> token.to_string(got)
  }
}

pub fn parse_literal(literal: Token) -> Parser(Nil) {
  fn(input: List(Token)) -> Result(ParserValue(Nil), ParserError) {
    case input {
      [] -> Error(MissingToken(expected: literal))
      [first, ..input] if first == literal -> {
        Ok(Value(input:, value: Nil))
      }
      [first, ..] -> Error(UnexpectedToken(expected: literal, got: first))
    }
  }
}

pub fn parse_string() -> Parser(String) {
  fn(input: List(Token)) -> Result(ParserValue(String), ParserError) {
    case input {
      [] -> Error(MissingToken(expected: token.String("")))
      [token.String(str:), ..input] -> Ok(Value(input:, value: str))
      [first, ..] ->
        Error(UnexpectedToken(expected: token.String(""), got: first))
    }
  }
}

pub fn parse_int() -> Parser(Int) {
  fn(input: List(Token)) -> Result(ParserValue(Int), ParserError) {
    case input {
      [] -> Error(MissingToken(expected: token.Integer(0)))
      [token.Integer(num:), ..input] -> Ok(Value(input:, value: num))
      [first, ..] ->
        Error(UnexpectedToken(expected: token.Integer(0), got: first))
    }
  }
}

pub fn parse_identifier() -> Parser(String) {
  fn(input: List(Token)) -> Result(ParserValue(String), ParserError) {
    case input {
      [] -> Error(MissingToken(expected: token.Identifier("")))
      [token.Identifier(name:), ..input] -> Ok(Value(input:, value: name))
      [first, ..] ->
        Error(UnexpectedToken(expected: token.Identifier(""), got: first))
    }
  }
}

pub fn parse_file() -> Parser(List(Node)) {
  combinator.repeat(combinator.choice([parse_function(), parse_eof()]))
}

pub fn parse_eof() -> Parser(Node) {
  fn(input) {
    case input {
      [] -> Ok(Value(value: ast.EOF, input: []))
      [_, ..] -> Error(NoMatchingParsers(tokens: input))
    }
  }
}

pub fn parse_function() -> Parser(Node) {
  let function_parser =
    combinator.sequential8(
      parse_literal(token.Function),
      parse_identifier(),
      parse_literal(token.LeftParenthesis),
      combinator.sequential2(
        combinator.repeat(combinator.sequential2(
          parse_identifier(),
          parse_literal(token.Comma),
        )),
        combinator.optional(parse_identifier()),
      ),
      parse_literal(token.RightParenthesis),
      parse_literal(token.LeftBrace),
      parse_expression(),
      parse_literal(token.RightBrace),
    )
  fn(input: List(Token)) -> Result(ParserValue(Node), ParserError) {
    case function_parser(input) {
      Error(error) -> Error(error)
      Ok(Value(value:, input:)) -> {
        let #(
          _,
          function_name,
          _,
          #(param_names, final_param),
          _,
          _,
          body_node,
          _,
        ) = value
        let param_names = list.map(param_names, pair.first)
        let param_names = case final_param {
          option.None -> param_names
          option.Some(final_param_name) ->
            list.append(param_names, [final_param_name])
        }
        Ok(Value(
          value: ast.Function(
            name: function_name,
            params: param_names,
            body: body_node,
          ),
          input:,
        ))
      }
    }
  }
}

pub fn parse_function_call() -> Parser(Node) {
  fn(input) {
    input
    |> combinator.map(
      combinator.sequential4(
        parse_identifier(),
        parse_literal(token.LeftParenthesis),
        combinator.sequential2(
          combinator.repeat(combinator.sequential2(
            parse_expression(),
            parse_literal(token.Comma),
          )),
          combinator.optional(parse_expression()),
        ),
        parse_literal(token.RightParenthesis),
      ),
      fn(tuple) {
        let #(function_name, _, #(args, final_arg), _) = tuple
        let args = args |> list.map(pair.first)
        let args = case final_arg {
          option.None -> args
          option.Some(final_arg) -> list.append(args, [final_arg])
        }
        ast.FunctionCall(name: function_name, args:)
      },
    )
  }
}

pub fn parse_expression() -> Parser(Node) {
  fn(input) {
    input
    |> combinator.choice([
      parse_function_call(),
      parse_let(),
      combinator.map(parse_int(), fn(num) { ast.Integer(num:) }),
      combinator.map(parse_string(), fn(str) { ast.String(str:) }),
      combinator.map(parse_identifier(), fn(name) { ast.Identifier(name:) }),
    ])
  }
}

pub fn parse_let() -> Parser(Node) {
  fn(input) {
    input
    |> combinator.map(
      combinator.sequential5(
        parse_literal(token.Let),
        parse_identifier(),
        parse_literal(token.Equals),
        parse_expression(),
        parse_expression(),
      ),
      fn(tuple) {
        let #(_, lhs, _, rhs, expr) = tuple
        ast.Let(lhs:, rhs:, body: expr)
      },
    )
  }
}
