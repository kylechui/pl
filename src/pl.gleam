import argv
import ast
import combinator
import gleam/io
import gleam/list
import lexer
import parser
import simplifile as file

pub fn main() {
  case argv.load().arguments {
    [] -> panic as "Missing file name. Usage: gleam run <file_name>"
    [file_name] ->
      file_name
      |> file.read
      |> fn(contents) {
        case contents {
          Error(_) -> panic as "Error reading file"
          Ok(contents) -> contents
        }
      }
      |> lexer.lex
      |> parser.parse_file()
      |> fn(result) {
        case result {
          Error(_) -> panic as "Parsing error"
          Ok(combinator.Value(value:, input: _input)) -> value
        }
      }
      |> list.map(ast.to_string)
      |> list.map(io.println)
    _ -> panic as "Too many arguments. Usage: gleam run <file_name>"
  }
}
