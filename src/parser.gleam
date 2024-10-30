import ast.{type Node}
import combinator.{type Parser, type ParserError, type ParserValue}
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import token.{type Token}

pub fn parse_file() -> Parser(#(List(Node), Nil)) {
  combinator.and2(combinator.repeat(parse_function()), combinator.eof())
}

pub fn parse_eof() -> Parser(Node) {
  fn(tokens) {
    case combinator.eof()(tokens) {
      Error(error) -> Error(error)
      Ok(_) -> Ok(combinator.ParserValue(value: ast.EOF, tokens: []))
    }
  }
}

pub fn parse_function() -> Parser(Node) {
  let function_parser =
    combinator.and8(
      combinator.literal(token.Function),
      combinator.identifier(),
      combinator.literal(token.LeftParenthesis),
      combinator.and2(
        combinator.repeat(combinator.and2(
          combinator.identifier(),
          combinator.literal(token.Comma),
        )),
        combinator.optional(combinator.identifier()),
      ),
      combinator.literal(token.RightParenthesis),
      combinator.literal(token.LeftBrace),
      parse_node(),
      combinator.literal(token.RightBrace),
    )
  fn(tokens: List(Token)) -> Result(ParserValue(Node), ParserError) {
    io.println_error("barely functioning")
    case function_parser(tokens) {
      Error(error) -> Error(error)
      Ok(combinator.ParserValue(value:, tokens:)) -> {
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
        let param_names =
          list.map(param_names, fn(pair) {
            let #(name, _) = pair
            name
          })
        let param_names = case final_param {
          option.None -> param_names
          option.Some(final_param_name) ->
            list.append(param_names, [final_param_name])
        }
        Ok(combinator.ParserValue(
          value: ast.Function(
            name: function_name,
            params: param_names,
            body: body_node,
          ),
          tokens:,
        ))
      }
    }
  }
}

pub fn parse_int() -> Parser(Node) {
  combinator.map(combinator.int(), fn(num) { ast.Integer(num:) })
}

pub fn parse_string() -> Parser(Node) {
  combinator.map(combinator.string(), fn(str) { ast.String(str:) })
}

pub fn parse_identifier() -> Parser(Node) {
  combinator.map(combinator.identifier(), fn(name) { ast.Identifier(name:) })
}

pub fn parse_node() -> Parser(Node) {
  fn(tokens) {
    tokens
    |> combinator.or([
      parse_int(),
      parse_string(),
      parse_identifier(),
      parse_let(),
    ])
  }
}

pub fn parse_let() -> Parser(Node) {
  fn(tokens) {
    tokens
    |> combinator.map(
      combinator.and5(
        combinator.literal(token.Let),
        combinator.identifier(),
        combinator.literal(token.Equals),
        parse_node(),
        parse_node(),
      ),
      fn(tuple) {
        let #(_, lhs, _, rhs, expr) = tuple
        ast.Let(lhs:, rhs:, body: expr)
      },
    )
  }
}
// pub fn parse_block() -> Parser(Node) {
//   combinator.map(
//     combinator.and3(
//       combinator.literal(token.LeftBrace),
//       parse_node(),
//       combinator.literal(token.RightBrace),
//     ),
//     fn(tuple) {
//       let #(_, a, _) = tuple
//       a
//     },
//   )
// }
// pub fn parse(tokens: List(token.Token)) -> #(List(token.Token), ast.Node) {
//   case tokens {
//     [] -> panic as "Parse error: Empty token list"
//     [token.String(_), ..] -> {
//       let #(tokens, string_node) = eat_string(tokens)
//       #(tokens, string_node)
//     }
//     [token.Function, ..] -> {
//       let #(tokens, function_node) = eat_function(tokens)
//       #(tokens, function_node)
//     }
//     [token.Let, ..] -> {
//       let #(tokens, let_node) = eat_let(tokens)
//       #(tokens, let_node)
//     }
//     [token.LeftBrace, ..] -> {
//       let #(tokens, block_node) = eat_block(tokens)
//       #(tokens, block_node)
//     }
//     [token.Identifier(_), token.LeftParenthesis, ..] -> {
//       let #(tokens, function_call_node) = eat_function_call(tokens)
//       #(tokens, function_call_node)
//     }
//     [token.Identifier(_), ..] -> {
//       let #(tokens, name) = eat_identifier(tokens)
//       #(tokens, ast.Identifier(name:))
//     }
//     _ -> todo
//   }
// }
//
// fn eat_literal(
//   tokens: List(token.Token),
//   literal: token.Token,
// ) -> List(token.Token) {
//   case tokens {
//     [] ->
//       panic as {
//         "Parse error(" <> token.to_string(literal) <> "): Missing tokens"
//       }
//     [first, ..tokens] if first == literal -> tokens
//     [first, ..] ->
//       panic as {
//         "Parse error: Expected "
//         <> token.to_string(literal)
//         <> ", got: "
//         <> token.to_string(first)
//       }
//   }
// }
//
// fn eat_string(tokens: List(token.Token)) -> #(List(token.Token), ast.Node) {
//   case tokens {
//     [] -> panic as "Parse error(String): Missing tokens"
//     [token.String(str:), ..tokens] -> #(tokens, ast.String(str:))
//     [token, ..] ->
//       panic as {
//         "Parse error(String): Expected String, got: " <> token.to_string(token)
//       }
//   }
// }
//
// fn eat_identifier(tokens: List(token.Token)) -> #(List(token.Token), String) {
//   case tokens {
//     [] -> panic as "Parse error(Identifier): Missing tokens"
//     [token.Identifier(name:), ..tokens] -> #(tokens, name)
//     [token, ..] ->
//       panic as {
//         "Parse error(Identifier): Expected Identifier, got: "
//         <> token.to_string(token)
//       }
//   }
// }
//
// fn eat_params(tokens: List(token.Token)) -> #(List(token.Token), List(String)) {
//   eat_params_helper(tokens, [])
// }
//
// fn eat_params_helper(
//   tokens: List(token.Token),
//   cur: List(String),
// ) -> #(List(token.Token), List(String)) {
//   case tokens {
//     [] -> panic as "Parse error(args): Missing tokens"
//     [token.RightParenthesis, ..] -> #(tokens, list.reverse(cur))
//     [token.Identifier(_), token.RightParenthesis, ..] -> {
//       let #(tokens, name) = eat_identifier(tokens)
//       #(tokens, list.reverse([name, ..cur]))
//     }
//     [token.Identifier(_), token.Comma, ..] -> {
//       let #(tokens, name) = eat_identifier(tokens)
//       let tokens = eat_literal(tokens, token.Comma)
//       eat_params_helper(tokens, [name, ..cur])
//     }
//     [token, ..] ->
//       panic as {
//         "Parse error(Identifier): Expected Identifier, got: "
//         <> token.to_string(token)
//       }
//   }
// }
//
// fn eat_args(tokens: List(token.Token)) -> #(List(token.Token), List(ast.Node)) {
//   eat_args_helper(tokens, [])
// }
//
// fn eat_args_helper(
//   tokens: List(token.Token),
//   cur: List(ast.Node),
// ) -> #(List(token.Token), List(ast.Node)) {
//   case tokens {
//     [] -> panic as "Parse error(args): Missing tokens"
//     [token.RightParenthesis, ..] -> #(tokens, list.reverse(cur))
//     tokens -> {
//       let #(tokens, arg) = parse(tokens)
//       case tokens {
//         [token.RightParenthesis, ..] -> #(tokens, list.reverse([arg, ..cur]))
//         [token.Comma, ..] -> {
//           let tokens = eat_literal(tokens, token.Comma)
//           eat_args_helper(tokens, [arg, ..cur])
//         }
//         _ -> panic as "Invalid function call syntax thing"
//       }
//     }
//   }
// }
//
// fn eat_function_call(
//   tokens: List(token.Token),
// ) -> #(List(token.Token), ast.Node) {
//   case tokens {
//     [] -> panic as "Parse error(FunctionCall): Missing tokens"
//     [token.Identifier(_), token.LeftParenthesis, ..] -> {
//       let #(tokens, name) = eat_identifier(tokens)
//       let tokens = eat_literal(tokens, token.LeftParenthesis)
//       let #(tokens, args) = eat_args(tokens)
//       let tokens = eat_literal(tokens, token.RightParenthesis)
//       #(tokens, ast.FunctionCall(name:, args:))
//     }
//     [token, ..] ->
//       panic as {
//         "Parse error(FunctionCall): Expected Identifier, token.LeftParenthesis, got: "
//         <> token.to_string(token)
//       }
//   }
// }
//
// fn eat_function(tokens: List(token.Token)) -> #(List(token.Token), ast.Node) {
//   case tokens {
//     [] -> panic as "Parse error(function): Missing tokens"
//     [token.Function, ..] -> {
//       let tokens = eat_literal(tokens, token.Function)
//       let #(tokens, name) = eat_identifier(tokens)
//       let tokens = eat_literal(tokens, token.LeftParenthesis)
//       let #(tokens, params) = eat_params(tokens)
//       let tokens = eat_literal(tokens, token.RightParenthesis)
//       let tokens = eat_literal(tokens, token.LeftBrace)
//       let #(tokens, body) = parse(tokens)
//       let tokens = eat_literal(tokens, token.RightBrace)
//       #(tokens, ast.Function(name:, params:, body:))
//     }
//     [token, ..] ->
//       panic as {
//         "Parse error(function): Expected function, got: "
//         <> token.to_string(token)
//       }
//   }
// }
//
// fn eat_let(tokens: List(token.Token)) -> #(List(token.Token), ast.Node) {
//   case tokens {
//     [] -> panic as "Parse error(Let): Missing tokens"
//     [token.Let, ..] -> {
//       let tokens = eat_literal(tokens, token.Let)
//       let #(tokens, lhs) = eat_identifier(tokens)
//       let tokens = eat_literal(tokens, token.Equals)
//       let #(tokens, rhs) = parse(tokens)
//       let #(tokens, body) = parse(tokens)
//       #(tokens, ast.Let(lhs:, rhs:, body:))
//     }
//     [token, ..] ->
//       panic as {
//         "Parse error(Let): Expected function, got: " <> token.to_string(token)
//       }
//   }
// }
//
// fn eat_statements(
//   tokens: List(token.Token),
// ) -> #(List(token.Token), List(ast.Node)) {
//   eat_statements_helper(tokens, [])
// }
//
// fn eat_statements_helper(
//   tokens: List(token.Token),
//   cur: List(ast.Node),
// ) -> #(List(token.Token), List(ast.Node)) {
//   case tokens {
//     [] -> panic as "Parse error(args): Missing tokens"
//     [token.RightBrace, ..] -> #(tokens, list.reverse(cur))
//     tokens -> {
//       let #(tokens, node) = parse(tokens)
//       eat_statements_helper(tokens, [node, ..cur])
//     }
//   }
// }
//
// fn eat_block(tokens: List(token.Token)) -> #(List(token.Token), ast.Node) {
//   case tokens {
//     [] -> panic as "Parse error(Block): Missing tokens"
//     [token.LeftBrace, ..] -> {
//       let tokens = eat_literal(tokens, token.LeftBrace)
//       let #(tokens, statements) = eat_statements(tokens)
//       let tokens = eat_literal(tokens, token.RightBrace)
//       #(tokens, ast.Block(statements:))
//     }
//     [token, ..] ->
//       panic as {
//         "Parse error(Block): Expected LeftBrace, got: "
//         <> token.to_string(token)
//       }
//   }
// }
