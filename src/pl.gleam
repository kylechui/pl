import argv
import ast
import gleam/io
import lexer
import parser
import simplifile as file

fn read_file(file_name: String) -> String {
  case file.read(file_name) {
    Error(_) -> panic as { "Could not read file: " <> file_name }
    Ok(contents) -> contents
  }
}

pub fn main() {
  case argv.load().arguments {
    [] -> panic as "Missing file name. Usage: gleam run <file_name>"
    [file_name] ->
      file_name
      |> read_file
      |> lexer.lex
      |> parser.parse
      |> fn(thing) {
        let #(_, node) = thing
        node
      }
      |> ast.to_string
      |> io.println
    _ -> panic as "Too many arguments. Usage: gleam run <file_name>"
  }
}
