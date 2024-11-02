import gleam/float
import gleam/int
import gleam/list
import gleam/regex
import gleam/string
import token.{type Token}

type State {
  Default
  InString
}

pub type LexError {
  InvalidEscapeSequence
  InvalidIdentifier(got: String)
}

pub fn lex(input: String) -> List(Result(Token, LexError)) {
  input
  |> string.to_graphemes
  |> internal_lex(Default, "", [])
  |> list.reverse
}

fn internal_lex(
  // List of characters
  input: List(String),
  state: State,
  cur: String,
  tokens: List(Result(Token, LexError)),
) -> List(Result(Token, LexError)) {
  case state {
    Default ->
      case input {
        [] -> add_identifier(cur, tokens)
        ["-", ">", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens)
          internal_lex(rest, Default, "", [Ok(token.Arrow), ..new_tokens])
        }
        [",", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens)
          internal_lex(rest, Default, "", [Ok(token.Comma), ..new_tokens])
        }
        ["\"", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens)
          internal_lex(rest, InString, "", new_tokens)
        }
        ["+", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens)
          internal_lex(rest, Default, "", [Ok(token.Plus), ..new_tokens])
        }
        ["=", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens)
          internal_lex(rest, Default, "", [Ok(token.Equals), ..new_tokens])
        }
        ["|", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens)
          internal_lex(rest, Default, "", [Ok(token.Pipe), ..new_tokens])
        }
        ["(", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens)
          internal_lex(rest, Default, "", [
            Ok(token.LeftParenthesis),
            ..new_tokens
          ])
        }
        [")", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens)
          internal_lex(rest, Default, "", [
            Ok(token.RightParenthesis),
            ..new_tokens
          ])
        }
        ["[", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens)
          internal_lex(rest, Default, "", [Ok(token.LeftBracket), ..new_tokens])
        }
        ["]", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens)
          internal_lex(rest, Default, "", [Ok(token.RightBracket), ..new_tokens])
        }
        ["{", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens)
          internal_lex(rest, Default, "", [Ok(token.LeftBrace), ..new_tokens])
        }
        ["}", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens)
          internal_lex(rest, Default, "", [Ok(token.RightBrace), ..new_tokens])
        }
        [" ", ..rest] | ["\t", ..rest] | ["\n", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens)
          internal_lex(rest, Default, "", new_tokens)
        }
        [first, ..rest] -> internal_lex(rest, Default, cur <> first, tokens)
      }
    InString ->
      case input {
        [] -> panic as "Lexing error: Cannot terminate program mid-string"
        ["\n", ..] -> panic as "Lexing error: Cannot terminate line mid-string"
        ["\\", "\\", ..rest] ->
          internal_lex(rest, InString, cur <> "\\", tokens)
        ["\\", "t", ..rest] -> internal_lex(rest, InString, cur <> "\t", tokens)
        ["\\", "n", ..rest] -> internal_lex(rest, InString, cur <> "\n", tokens)
        ["\\", "\"", ..rest] ->
          internal_lex(rest, InString, cur <> "\"", tokens)
        ["\\", ..] -> panic as "Lexing error: Invalid escape character detected"
        ["\"", ..rest] ->
          internal_lex(rest, Default, "", [Ok(token.String(str: cur)), ..tokens])
        [first, ..rest] -> internal_lex(rest, InString, cur <> first, tokens)
      }
  }
}

fn add_identifier(
  cur: String,
  tokens: List(Result(Token, LexError)),
) -> List(Result(Token, LexError)) {
  case cur {
    "" -> tokens
    "fn" -> [Ok(token.Function), ..tokens]
    "let" -> [Ok(token.Let), ..tokens]
    "pub" -> [Ok(token.Public), ..tokens]
    "match" -> [Ok(token.Match), ..tokens]
    cur -> {
      // TODO: Is there a way to avoid this nesting?
      case int.parse(cur) {
        Ok(num) -> [Ok(token.Integer(num:)), ..tokens]
        Error(Nil) ->
          case float.parse(cur) {
            Ok(num) -> [Ok(token.Float(num:)), ..tokens]
            Error(Nil) -> {
              let assert Ok(identifier_regex) =
                regex.from_string("^[a-z_][a-z0-9_]*$")
              case regex.check(with: identifier_regex, content: cur) {
                True -> [Ok(token.Identifier(name: cur)), ..tokens]
                False -> [Error(InvalidIdentifier(got: cur)), ..tokens]
              }
            }
          }
      }
    }
  }
}
