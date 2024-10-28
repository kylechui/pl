import gleam/int

pub type Token {
  Equals
  Identifier(name: String)
  LeftBrace
  LeftBracket
  LeftParenthesis
  Let
  Integer(num: Int)
  Match
  Plus
  Comma
  RightBrace
  RightBracket
  Function
  RightParenthesis
  Pipe
  Arrow
  String(str: String)
  Public
}

pub fn to_string(token: Token) -> String {
  case token {
    Equals -> "Equals"
    Identifier(name:) -> "Identifier(" <> name <> ")"
    LeftBrace -> "LeftBrace"
    LeftBracket -> "LeftBracket"
    LeftParenthesis -> "LeftParenthesis"
    Let -> "Let"
    Integer(num:) -> "Number(" <> int.to_string(num) <> ")"
    Plus -> "Plus"
    RightBrace -> "RightBrace"
    RightBracket -> "RightBracket"
    RightParenthesis -> "RightParenthesis"
    String(str:) -> "String(" <> str <> ")"
    Match -> "Match"
    Pipe -> "Pipe"
    Arrow -> "Arrow"
    Function -> "Function"
    Public -> "Public"
    Comma -> "Comma"
  }
}
