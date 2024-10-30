import argv
import ast
import combinator
import gleam/int
import gleam/io
import gleam/list
import lexer
import parser
import simplifile as file
import token

pub fn main() {
  case argv.load().arguments {
    [] -> panic as "Missing file name. Usage: gleam run <file_name>"
    [file_name] ->
      file_name
      // |> read_file
      |> lexer.lex
      |> parser.parse_file()
      |> fn(result) {
        case result {
          Error(error) -> panic as combinator.show_error(error)
          Ok(combinator.ParserValue(value: #(value, _), tokens: _tokens)) ->
            value
        }
      }
      // |> ast.to_string
      // |> io.println
      |> list.map(ast.to_string)
      |> list.map(io.println)
    _ -> panic as "Too many arguments. Usage: gleam run <file_name>"
  }
}
