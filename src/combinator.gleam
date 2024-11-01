import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result

pub type Value(input_type, output_type) {
  Value(input: input_type, value: output_type)
}

pub type Parser(input_type, output_type, error_type) =
  fn(input_type) -> Result(Value(input_type, output_type), error_type)

pub fn map(parser: Parser(s, t, e), mapper: fn(t) -> u) -> Parser(s, u, e) {
  fn(input: s) -> Result(Value(s, u), e) {
    case parser(input) {
      Error(error) -> Error(error)
      Ok(Value(value:, input:)) -> Ok(Value(value: mapper(value), input:))
    }
  }
}

pub fn sequential2(
  parser1: Parser(s, t1, e),
  parser2: Parser(s, t2, e),
) -> Parser(s, #(t1, t2), e) {
  fn(input: s) -> Result(Value(s, #(t1, t2)), e) {
    use Value(input:, value: value1) <- result.try(parser1(input))
    use Value(input:, value: value2) <- result.try(parser2(input))
    Ok(Value(input:, value: #(value1, value2)))
  }
}

pub fn sequential3(
  parser1: Parser(s, t1, e),
  parser2: Parser(s, t2, e),
  parser3: Parser(s, t3, e),
) -> Parser(s, #(t1, t2, t3), e) {
  fn(input: s) -> Result(Value(s, #(t1, t2, t3)), e) {
    use Value(input:, value: value1) <- result.try(parser1(input))
    use Value(input:, value: value2) <- result.try(parser2(input))
    use Value(input:, value: value3) <- result.try(parser3(input))
    Ok(Value(input:, value: #(value1, value2, value3)))
  }
}

pub fn sequential4(
  parser1: Parser(s, t1, e),
  parser2: Parser(s, t2, e),
  parser3: Parser(s, t3, e),
  parser4: Parser(s, t4, e),
) -> Parser(s, #(t1, t2, t3, t4), e) {
  fn(input: s) -> Result(Value(s, #(t1, t2, t3, t4)), e) {
    use Value(input:, value: value1) <- result.try(parser1(input))
    use Value(input:, value: value2) <- result.try(parser2(input))
    use Value(input:, value: value3) <- result.try(parser3(input))
    use Value(input:, value: value4) <- result.try(parser4(input))
    Ok(Value(input:, value: #(value1, value2, value3, value4)))
  }
}

pub fn sequential5(
  parser1: Parser(s, t1, e),
  parser2: Parser(s, t2, e),
  parser3: Parser(s, t3, e),
  parser4: Parser(s, t4, e),
  parser5: Parser(s, t5, e),
) -> Parser(s, #(t1, t2, t3, t4, t5), e) {
  fn(input: s) -> Result(Value(s, #(t1, t2, t3, t4, t5)), e) {
    use Value(input:, value: value1) <- result.try(parser1(input))
    use Value(input:, value: value2) <- result.try(parser2(input))
    use Value(input:, value: value3) <- result.try(parser3(input))
    use Value(input:, value: value4) <- result.try(parser4(input))
    use Value(input:, value: value5) <- result.try(parser5(input))
    Ok(Value(input:, value: #(value1, value2, value3, value4, value5)))
  }
}

pub fn sequential6(
  parser1: Parser(s, t1, e),
  parser2: Parser(s, t2, e),
  parser3: Parser(s, t3, e),
  parser4: Parser(s, t4, e),
  parser5: Parser(s, t5, e),
  parser6: Parser(s, t6, e),
) -> Parser(s, #(t1, t2, t3, t4, t5, t6), e) {
  fn(input: s) -> Result(Value(s, #(t1, t2, t3, t4, t5, t6)), e) {
    use Value(input:, value: value1) <- result.try(parser1(input))
    use Value(input:, value: value2) <- result.try(parser2(input))
    use Value(input:, value: value3) <- result.try(parser3(input))
    use Value(input:, value: value4) <- result.try(parser4(input))
    use Value(input:, value: value5) <- result.try(parser5(input))
    use Value(input:, value: value6) <- result.try(parser6(input))
    Ok(Value(input:, value: #(value1, value2, value3, value4, value5, value6)))
  }
}

pub fn sequential7(
  parser1: Parser(s, t1, e),
  parser2: Parser(s, t2, e),
  parser3: Parser(s, t3, e),
  parser4: Parser(s, t4, e),
  parser5: Parser(s, t5, e),
  parser6: Parser(s, t6, e),
  parser7: Parser(s, t7, e),
) -> Parser(s, #(t1, t2, t3, t4, t5, t6, t7), e) {
  fn(input: s) -> Result(Value(s, #(t1, t2, t3, t4, t5, t6, t7)), e) {
    use Value(input:, value: value1) <- result.try(parser1(input))
    use Value(input:, value: value2) <- result.try(parser2(input))
    use Value(input:, value: value3) <- result.try(parser3(input))
    use Value(input:, value: value4) <- result.try(parser4(input))
    use Value(input:, value: value5) <- result.try(parser5(input))
    use Value(input:, value: value6) <- result.try(parser6(input))
    use Value(input:, value: value7) <- result.try(parser7(input))
    Ok(
      Value(input:, value: #(
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

pub fn sequential8(
  parser1: Parser(s, t1, e),
  parser2: Parser(s, t2, e),
  parser3: Parser(s, t3, e),
  parser4: Parser(s, t4, e),
  parser5: Parser(s, t5, e),
  parser6: Parser(s, t6, e),
  parser7: Parser(s, t7, e),
  parser8: Parser(s, t8, e),
) -> Parser(s, #(t1, t2, t3, t4, t5, t6, t7, t8), e) {
  fn(input: s) -> Result(Value(s, #(t1, t2, t3, t4, t5, t6, t7, t8)), e) {
    use Value(input:, value: value1) <- result.try(parser1(input))
    use Value(input:, value: value2) <- result.try(parser2(input))
    use Value(input:, value: value3) <- result.try(parser3(input))
    use Value(input:, value: value4) <- result.try(parser4(input))
    use Value(input:, value: value5) <- result.try(parser5(input))
    use Value(input:, value: value6) <- result.try(parser6(input))
    use Value(input:, value: value7) <- result.try(parser7(input))
    use Value(input:, value: value8) <- result.try(parser8(input))
    Ok(
      Value(input:, value: #(
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

pub fn choice(parsers: List(Parser(s, t, e))) -> Parser(s, t, e) {
  fn(input: s) -> Result(Value(s, t), e) {
    case parsers {
      [] -> panic
      [parser, ..parsers] -> {
        case parser(input) {
          Error(_) -> choice(parsers)(input)
          Ok(value) -> Ok(value)
        }
      }
    }
  }
}

/// Will never yield a e, since it can just not parse
pub fn optional(parser: Parser(s, t, e)) -> Parser(s, Option(t), e) {
  fn(input: s) -> Result(Value(s, Option(t)), e) {
    case parser(input) {
      Error(_) -> Ok(Value(value: None, input:))
      Ok(Value(value:, input:)) -> Ok(Value(value: Some(value), input:))
    }
  }
}

fn repeat_helper(parser: Parser(s, t, e), input: s) -> Value(s, List(t)) {
  case parser(input) {
    Error(_) -> Value(value: [], input:)
    Ok(Value(value:, input:)) -> {
      let Value(value: values, input:) = repeat_helper(parser, input)
      Value(value: [value, ..values], input:)
    }
  }
}

/// Will never yield an error, since it can just not parse
pub fn repeat(parser: Parser(s, t, e)) -> Parser(s, List(t), e) {
  fn(input: s) -> Result(Value(s, List(t)), e) {
    Ok(repeat_helper(parser, input))
  }
}

pub fn sequential(parsers: List(Parser(s, t, e))) -> Parser(s, List(t), e) {
  fn(input: s) -> Result(Value(s, List(t)), e) {
    list.fold(parsers, Ok(Value(input:, value: [])), fn(result, parser) {
      case result {
        Error(error) -> Error(error)
        Ok(Value(value: values, input:)) ->
          case parser(input) {
            Error(error) -> Error(error)
            Ok(Value(value:, input:)) ->
              // TODO: Figure out where to put the list.reverse to make this
              //       linear instead of quadratic time
              Ok(Value(value: list.append(values, [value]), input:))
          }
      }
    })
  }
}
