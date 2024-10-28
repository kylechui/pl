import gleam/int
import gleam/list
import gleam/string
import token.{type Token}

type State {
  Default
  InString
  // InMultilineString
}

pub fn lex(input: String) -> List(Token) {
  input
  |> string.split(on: "\n")
  |> list.flat_map(string.to_graphemes)
  |> internal_lex(Default, "", [])
  |> list.reverse
}

fn internal_lex(
  // List of characters
  input: List(String),
  state: State,
  cur: String,
  tokens: List(Token),
) -> List(Token) {
  case state {
    Default ->
      case input {
        [] -> add_identifier(cur, tokens)
        // TODO: There has to be a better way to do this :skull:
        ["-", ">", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens)
          internal_lex(rest, Default, "", [token.Arrow, ..new_tokens])
        }
        [",", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens)
          internal_lex(rest, Default, "", [token.Comma, ..new_tokens])
        }
        ["\"", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens)
          internal_lex(rest, InString, "", new_tokens)
        }
        ["+", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens)
          internal_lex(rest, Default, "", [token.Plus, ..new_tokens])
        }
        ["=", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens)
          internal_lex(rest, Default, "", [token.Equals, ..new_tokens])
        }
        ["(", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens)
          internal_lex(rest, Default, "", [token.LeftParenthesis, ..new_tokens])
        }
        [")", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens)
          internal_lex(rest, Default, "", [token.RightParenthesis, ..new_tokens])
        }
        ["[", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens)
          internal_lex(rest, Default, "", [token.LeftBracket, ..new_tokens])
        }
        ["]", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens)
          internal_lex(rest, Default, "", [token.RightBracket, ..new_tokens])
        }
        ["{", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens)
          internal_lex(rest, Default, "", [token.LeftBrace, ..new_tokens])
        }
        ["}", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens)
          internal_lex(rest, Default, "", [token.RightBrace, ..new_tokens])
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
          internal_lex(rest, Default, cur <> "\"", [token.String(cur), ..tokens])
        ["\\", ..] -> panic as "Lexing error: Invalid escape character detected"
        ["\"", ..rest] ->
          internal_lex(rest, Default, "", [token.String(cur), ..tokens])
        [first, ..rest] -> internal_lex(rest, InString, cur <> first, tokens)
      }
  }
}

fn add_identifier(cur: String, tokens: List(Token)) -> List(Token) {
  case cur {
    "" -> tokens
    "fn" -> [token.Function, ..tokens]
    "let" -> [token.Let, ..tokens]
    "pub" -> [token.Public, ..tokens]
    "match" -> [token.Match, ..tokens]
    cur ->
      case int.parse(cur) {
        // TODO: Deal with floats!
        Ok(num) -> [token.Integer(num:), ..tokens]
        Error(Nil) -> [token.Identifier(cur), ..tokens]
      }
  }
}
