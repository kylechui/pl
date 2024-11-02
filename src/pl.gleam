import argv

pub fn main() {
  case argv.load().arguments {
    [] -> panic as "Missing file name. Usage: gleam run <file_name>"
    [_file_name] -> todo as "Implement me after the components are more sane!"
    _ -> panic as "Too many arguments. Usage: gleam run <file_name>"
  }
}
