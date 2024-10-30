import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import token.{type Token}

pub type ParserError {
  MissingToken(expected: Token)
  UnexpectedToken(expected: Token, got: Token)
  NoMatchingParsers(tokens: List(Token))
}

pub fn show_error(parser_error: ParserError) -> String {
  case parser_error {
    MissingToken(expected:) ->
      "Token stream terminated unexpectedly; expected: "
      <> token.to_string(expected)
    NoMatchingParsers(tokens:) ->
      "No matching parsers for token stream: "
      <> { tokens |> list.map(token.to_string) |> string.join(with: ", ") }
    UnexpectedToken(expected:, got:) ->
      "Unexpected token found. Expected: "
      <> token.to_string(expected)
      <> " but got: "
      <> token.to_string(got)
  }
}

pub type ParserValue(value) {
  ParserValue(tokens: List(Token), value: value)
}

pub type Parser(value) =
  fn(List(Token)) -> Result(ParserValue(value), ParserError)

pub fn eof() -> Parser(Nil) {
  fn(tokens: List(Token)) -> Result(ParserValue(Nil), ParserError) {
    io.println_error("eating eof")
    case tokens {
      [] -> Ok(ParserValue(value: Nil, tokens: []))
      [_, ..] -> Error(NoMatchingParsers(tokens:))
    }
  }
}

pub fn literal(literal: Token) -> Parser(Nil) {
  fn(tokens: List(Token)) -> Result(ParserValue(Nil), ParserError) {
    io.println_error("eating literal: " <> token.to_string(literal))
    case tokens {
      [] -> Error(MissingToken(expected: literal))
      [first, ..tokens] if first == literal -> {
        Ok(ParserValue(tokens:, value: Nil))
      }
      [first, ..] -> Error(UnexpectedToken(expected: literal, got: first))
    }
  }
}

pub fn string() -> Parser(String) {
  fn(tokens: List(Token)) -> Result(ParserValue(String), ParserError) {
    io.println_error("eating string")
    case tokens {
      [] -> Error(MissingToken(expected: token.String("")))
      [token.String(str:), ..tokens] -> Ok(ParserValue(tokens:, value: str))
      [first, ..] ->
        Error(UnexpectedToken(expected: token.String(""), got: first))
    }
  }
}

pub fn int() -> Parser(Int) {
  fn(tokens: List(Token)) -> Result(ParserValue(Int), ParserError) {
    io.println_error("eating int")
    case tokens {
      [] -> Error(MissingToken(expected: token.Integer(0)))
      [token.Integer(num:), ..tokens] -> Ok(ParserValue(tokens:, value: num))
      [first, ..] ->
        Error(UnexpectedToken(expected: token.Integer(0), got: first))
    }
  }
}

pub fn identifier() -> Parser(String) {
  fn(tokens: List(Token)) -> Result(ParserValue(String), ParserError) {
    io.println_error("eating identifier")
    case tokens {
      [] -> Error(MissingToken(expected: token.Identifier("")))
      [token.Identifier(name:), ..tokens] ->
        Ok(ParserValue(tokens:, value: name))
      [first, ..] ->
        Error(UnexpectedToken(expected: token.Identifier(""), got: first))
    }
  }
}

pub fn map(parser: Parser(s), mapper: fn(s) -> t) -> Parser(t) {
  fn(tokens: List(Token)) -> Result(ParserValue(t), ParserError) {
    io.println_error("mappin")
    case parser(tokens) {
      Error(error) -> Error(error)
      Ok(ParserValue(value:, tokens:)) ->
        Ok(ParserValue(value: mapper(value), tokens:))
    }
  }
}

pub fn and2(parser1: Parser(a), parser2: Parser(b)) -> Parser(#(a, b)) {
  fn(tokens: List(Token)) -> Result(ParserValue(#(a, b)), ParserError) {
    io.println_error("and2")
    case parser1(tokens) {
      Error(error) -> {
        io.println_error("p1 failed")
        Error(error)
      }
      Ok(ParserValue(tokens:, value: value1)) ->
        case parser2(tokens) {
          Error(error) -> Error(error)
          Ok(ParserValue(tokens:, value: value2)) ->
            Ok(ParserValue(tokens:, value: #(value1, value2)))
        }
    }
  }
}

// pub fn and2(parser1: Parser(a), parser2: Parser(b)) -> Parser(#(a, b)) {
//   fn(tokens: List(Token)) -> Result(ParserValue(#(a, b)), ParserError) {
//     use ParserValue(tokens:, value: value1) <- result.try(parser1(tokens))
//     use ParserValue(tokens:, value: value2) <- result.try(parser2(tokens))
//     Ok(ParserValue(tokens:, value: #(value1, value2)))
//   }
// }

pub fn and3(
  parser1: Parser(a),
  parser2: Parser(b),
  parser3: Parser(c),
) -> Parser(#(a, b, c)) {
  fn(tokens: List(Token)) -> Result(ParserValue(#(a, b, c)), ParserError) {
    use ParserValue(tokens:, value: value1) <- result.try(parser1(tokens))
    use ParserValue(tokens:, value: value2) <- result.try(parser2(tokens))
    use ParserValue(tokens:, value: value3) <- result.try(parser3(tokens))
    Ok(ParserValue(tokens:, value: #(value1, value2, value3)))
  }
}

pub fn and4(
  parser1: Parser(a),
  parser2: Parser(b),
  parser3: Parser(c),
  parser4: Parser(d),
) -> Parser(#(a, b, c, d)) {
  fn(tokens: List(Token)) -> Result(ParserValue(#(a, b, c, d)), ParserError) {
    use ParserValue(tokens:, value: value1) <- result.try(parser1(tokens))
    use ParserValue(tokens:, value: value2) <- result.try(parser2(tokens))
    use ParserValue(tokens:, value: value3) <- result.try(parser3(tokens))
    use ParserValue(tokens:, value: value4) <- result.try(parser4(tokens))
    Ok(ParserValue(tokens:, value: #(value1, value2, value3, value4)))
  }
}

pub fn and5(
  parser1: Parser(a),
  parser2: Parser(b),
  parser3: Parser(c),
  parser4: Parser(d),
  parser5: Parser(e),
) -> Parser(#(a, b, c, d, e)) {
  fn(tokens: List(Token)) -> Result(ParserValue(#(a, b, c, d, e)), ParserError) {
    io.println_error("andin 5")
    use ParserValue(tokens:, value: value1) <- result.try(parser1(tokens))
    use ParserValue(tokens:, value: value2) <- result.try(parser2(tokens))
    use ParserValue(tokens:, value: value3) <- result.try(parser3(tokens))
    use ParserValue(tokens:, value: value4) <- result.try(parser4(tokens))
    use ParserValue(tokens:, value: value5) <- result.try(parser5(tokens))
    Ok(ParserValue(tokens:, value: #(value1, value2, value3, value4, value5)))
  }
}

pub fn and6(
  parser1: Parser(a),
  parser2: Parser(b),
  parser3: Parser(c),
  parser4: Parser(d),
  parser5: Parser(e),
  parser6: Parser(f),
) -> Parser(#(a, b, c, d, e, f)) {
  fn(tokens: List(Token)) -> Result(
    ParserValue(#(a, b, c, d, e, f)),
    ParserError,
  ) {
    use ParserValue(tokens:, value: value1) <- result.try(parser1(tokens))
    use ParserValue(tokens:, value: value2) <- result.try(parser2(tokens))
    use ParserValue(tokens:, value: value3) <- result.try(parser3(tokens))
    use ParserValue(tokens:, value: value4) <- result.try(parser4(tokens))
    use ParserValue(tokens:, value: value5) <- result.try(parser5(tokens))
    use ParserValue(tokens:, value: value6) <- result.try(parser6(tokens))
    Ok(
      ParserValue(tokens:, value: #(
        value1,
        value2,
        value3,
        value4,
        value5,
        value6,
      )),
    )
  }
}

pub fn and7(
  parser1: Parser(a),
  parser2: Parser(b),
  parser3: Parser(c),
  parser4: Parser(d),
  parser5: Parser(e),
  parser6: Parser(f),
  parser7: Parser(g),
) -> Parser(#(a, b, c, d, e, f, g)) {
  fn(tokens: List(Token)) -> Result(
    ParserValue(#(a, b, c, d, e, f, g)),
    ParserError,
  ) {
    use ParserValue(tokens:, value: value1) <- result.try(parser1(tokens))
    use ParserValue(tokens:, value: value2) <- result.try(parser2(tokens))
    use ParserValue(tokens:, value: value3) <- result.try(parser3(tokens))
    use ParserValue(tokens:, value: value4) <- result.try(parser4(tokens))
    use ParserValue(tokens:, value: value5) <- result.try(parser5(tokens))
    use ParserValue(tokens:, value: value6) <- result.try(parser6(tokens))
    use ParserValue(tokens:, value: value7) <- result.try(parser7(tokens))
    Ok(
      ParserValue(tokens:, value: #(
        value1,
        value2,
        value3,
        value4,
        value5,
        value6,
        value7,
      )),
    )
  }
}

pub fn and8(
  parser1: Parser(a),
  parser2: Parser(b),
  parser3: Parser(c),
  parser4: Parser(d),
  parser5: Parser(e),
  parser6: Parser(f),
  parser7: Parser(g),
  parser8: Parser(h),
) -> Parser(#(a, b, c, d, e, f, g, h)) {
  io.println_error("ANDING")
  fn(tokens: List(Token)) -> Result(
    ParserValue(#(a, b, c, d, e, f, g, h)),
    ParserError,
  ) {
    io.println_error("and")
    use ParserValue(tokens:, value: value1) <- result.try(parser1(tokens))
    use ParserValue(tokens:, value: value2) <- result.try(parser2(tokens))
    use ParserValue(tokens:, value: value3) <- result.try(parser3(tokens))
    use ParserValue(tokens:, value: value4) <- result.try(parser4(tokens))
    use ParserValue(tokens:, value: value5) <- result.try(parser5(tokens))
    use ParserValue(tokens:, value: value6) <- result.try(parser6(tokens))
    use ParserValue(tokens:, value: value7) <- result.try(parser7(tokens))
    use ParserValue(tokens:, value: value8) <- result.try(parser8(tokens))
    Ok(
      ParserValue(tokens:, value: #(
        value1,
        value2,
        value3,
        value4,
        value5,
        value6,
        value7,
        value8,
      )),
    )
  }
}

pub fn or(parsers: List(Parser(t))) -> Parser(t) {
  fn(tokens: List(Token)) -> Result(ParserValue(t), ParserError) {
    case parsers {
      [] -> Error(NoMatchingParsers(tokens:))
      [parser, ..parsers] -> {
        case parser(tokens) {
          Error(_) -> or(parsers)(tokens)
          Ok(value) -> Ok(value)
        }
      }
    }
  }
}

/// Will never yield a ParseError, since it can just not parse
pub fn optional(parser: Parser(t)) -> Parser(Option(t)) {
  fn(tokens: List(Token)) -> Result(ParserValue(Option(t)), ParserError) {
    case parser(tokens) {
      Error(_) -> Ok(ParserValue(value: None, tokens:))
      Ok(ParserValue(value:, tokens:)) ->
        Ok(ParserValue(value: Some(value), tokens:))
    }
  }
}

fn repeat_helper(parser: Parser(t), tokens: List(Token)) -> ParserValue(List(t)) {
  io.println_error("repeat helper")
  case parser(tokens) {
    Error(_) -> ParserValue(value: [], tokens:)
    Ok(ParserValue(value:, tokens:)) -> {
      let ParserValue(value: values, tokens:) = repeat_helper(parser, tokens)
      ParserValue(value: [value, ..values], tokens:)
    }
  }
}

/// Will never yield a ParseError, since it can just not parse
pub fn repeat(parser: Parser(t)) -> Parser(List(t)) {
  fn(tokens: List(Token)) -> Result(ParserValue(List(t)), ParserError) {
    io.println_error("repeating!")
    let ParserValue(value:, tokens: _) = repeat_helper(parser, tokens)
    io.println_error(
      "value.size == " <> { value |> list.length |> int.to_string },
    )
    Ok(repeat_helper(parser, tokens))
  }
}

pub fn sequential(parsers: List(Parser(t))) -> Parser(List(t)) {
  fn(tokens: List(Token)) -> Result(ParserValue(List(t)), ParserError) {
    list.fold(parsers, Ok(ParserValue(tokens:, value: [])), fn(result, parser) {
      case result {
        Error(error) -> Error(error)
        Ok(ParserValue(value: values, tokens:)) ->
          case parser(tokens) {
            Error(error) -> Error(error)
            Ok(ParserValue(value:, tokens:)) ->
              // TODO: Figure out where to put the list.reverse to make this
              //       linear instead of quadratic time
              Ok(ParserValue(value: list.append(values, [value]), tokens:))
          }
      }
    })
  }
}
