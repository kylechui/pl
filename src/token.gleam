import gleam/int

pub type Token {
  Arrow
  Comma
  Equals
  Function
  Identifier(name: String)
  Integer(num: Int)
  LeftBrace
  LeftBracket
  LeftParenthesis
  Let
  Match
  Pipe
  Plus
  Public
  RightBrace
  RightBracket
  RightParenthesis
  String(str: String)
}

pub fn to_string(token: Token) -> String {
  case token {
    Arrow -> "Arrow"
    Comma -> "Comma"
    Equals -> "Equals"
    Function -> "Function"
    Identifier(name:) -> "Identifier(" <> name <> ")"
    Integer(num:) -> "Integer(" <> int.to_string(num) <> ")"
    LeftBrace -> "LeftBrace"
    LeftBracket -> "LeftBracket"
    LeftParenthesis -> "LeftParenthesis"
    Let -> "Let"
    Match -> "Match"
    Pipe -> "Pipe"
    Plus -> "Plus"
    Public -> "Public"
    RightBrace -> "RightBrace"
    RightBracket -> "RightBracket"
    RightParenthesis -> "RightParenthesis"
    String(str:) -> "String(" <> str <> ")"
  }
}
