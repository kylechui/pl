import buffer.{type Index}
import gleam/float
import gleam/int
import gleam/list
import gleam/regex
import gleam/string
import token.{type Token}

type State {
  Default(index: Index)
  InString(start_index: Index, index: Index)
}

pub type LexError {
  StringTermination
  InvalidEscapeSequence
  InvalidIdentifier(got: String)
}

type IndexedResult =
  #(Result(Token, LexError), Index)

pub fn lex(input: String) -> List(IndexedResult) {
  input
  |> string.to_graphemes
  |> internal_lex(Default(index: 0), "", [])
  |> list.reverse
}

fn internal_lex(
  // List of characters
  input: List(String),
  state: State,
  cur: String,
  tokens: List(IndexedResult),
) -> List(IndexedResult) {
  case state {
    Default(index:) ->
      case input {
        [] -> add_identifier(cur, tokens, index)
        ["-", ">", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens, index)
          internal_lex(rest, Default(index: index + 2), "", [
            #(Ok(token.Arrow), index),
            ..new_tokens
          ])
        }
        [",", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens, index)
          internal_lex(rest, Default(index: index + 1), "", [
            #(Ok(token.Comma), index),
            ..new_tokens
          ])
        }
        ["\"", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens, index)
          internal_lex(
            rest,
            InString(start_index: index, index: index + 1),
            "",
            new_tokens,
          )
        }
        ["+", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens, index)
          internal_lex(rest, Default(index: index + 1), "", [
            #(Ok(token.Plus), index),
            ..new_tokens
          ])
        }
        ["=", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens, index)
          internal_lex(rest, Default(index: index + 1), "", [
            #(Ok(token.Equals), index),
            ..new_tokens
          ])
        }
        ["|", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens, index)
          internal_lex(rest, Default(index: index + 1), "", [
            #(Ok(token.Pipe), index),
            ..new_tokens
          ])
        }
        ["(", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens, index)
          internal_lex(rest, Default(index: index + 1), "", [
            #(Ok(token.LeftParenthesis), index),
            ..new_tokens
          ])
        }
        [")", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens, index)
          internal_lex(rest, Default(index: index + 1), "", [
            #(Ok(token.RightParenthesis), index),
            ..new_tokens
          ])
        }
        ["[", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens, index)
          internal_lex(rest, Default(index: index + 1), "", [
            #(Ok(token.LeftBracket), index),
            ..new_tokens
          ])
        }
        ["]", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens, index)
          internal_lex(rest, Default(index: index + 1), "", [
            #(Ok(token.RightBracket), index),
            ..new_tokens
          ])
        }
        ["{", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens, index)
          internal_lex(rest, Default(index: index + 1), "", [
            #(Ok(token.LeftBrace), index),
            ..new_tokens
          ])
        }
        ["}", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens, index)
          internal_lex(rest, Default(index: index + 1), "", [
            #(Ok(token.RightBrace), index),
            ..new_tokens
          ])
        }
        [" ", ..rest] | ["\t", ..rest] | ["\n", ..rest] -> {
          let new_tokens = add_identifier(cur, tokens, index)
          internal_lex(rest, Default(index: index + 1), "", new_tokens)
        }
        [first, ..rest] ->
          internal_lex(rest, Default(index: index + 1), cur <> first, tokens)
      }
    InString(start_index:, index:) ->
      case input {
        [] | ["\n", ..] -> [#(Error(StringTermination), index), ..tokens]
        ["\\", "\\", ..rest] ->
          internal_lex(
            rest,
            InString(start_index:, index: index + 2),
            cur <> "\\",
            tokens,
          )
        ["\\", "t", ..rest] ->
          internal_lex(
            rest,
            InString(start_index:, index: index + 2),
            cur <> "\t",
            tokens,
          )
        ["\\", "n", ..rest] ->
          internal_lex(
            rest,
            InString(start_index:, index: index + 2),
            cur <> "\n",
            tokens,
          )
        ["\\", "\"", ..rest] ->
          internal_lex(
            rest,
            InString(start_index:, index: index + 2),
            cur <> "\"",
            tokens,
          )
        ["\\", ..] -> [#(Error(InvalidEscapeSequence), index), ..tokens]
        ["\"", ..rest] ->
          internal_lex(rest, Default(index: index + 1), "", [
            #(Ok(token.String(str: cur)), start_index),
            ..tokens
          ])
        [first, ..rest] ->
          internal_lex(
            rest,
            InString(start_index:, index: index + 1),
            cur <> first,
            tokens,
          )
      }
  }
}

fn add_identifier(
  cur: String,
  tokens: List(IndexedResult),
  index: Index,
) -> List(IndexedResult) {
  case cur {
    "" -> tokens
    "fn" -> [#(Ok(token.Function), index - string.length(cur)), ..tokens]
    "let" -> [#(Ok(token.Let), index - string.length(cur)), ..tokens]
    "pub" -> [#(Ok(token.Public), index - string.length(cur)), ..tokens]
    "match" -> [#(Ok(token.Match), index - string.length(cur)), ..tokens]
    cur -> {
      // TODO: Is there a way to avoid this nesting?
      case int.parse(cur) {
        Ok(num) -> [
          #(Ok(token.Integer(num:)), index - string.length(cur)),
          ..tokens
        ]
        Error(Nil) ->
          case float.parse(cur) {
            Ok(num) -> [
              #(Ok(token.Float(num:)), index - string.length(cur)),
              ..tokens
            ]
            Error(Nil) -> {
              let assert Ok(identifier_regex) =
                regex.from_string("^[a-z_][a-z0-9_]*$")
              case regex.check(with: identifier_regex, content: cur) {
                True -> [
                  #(Ok(token.Identifier(name: cur)), index - string.length(cur)),
                  ..tokens
                ]
                False -> [
                  #(
                    Error(InvalidIdentifier(got: cur)),
                    index - string.length(cur),
                  ),
                  ..tokens
                ]
              }
            }
          }
      }
    }
  }
}
