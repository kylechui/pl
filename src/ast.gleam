import gleam/json
import gleam/list

pub type Node {
  Let(lhs: String, rhs: Node, body: Node)
  Function(name: String, params: List(String), body: Node)
  FunctionCall(name: String, args: List(Node))
  Block(statements: List(Node))
  Identifier(name: String)
  Integer(num: Int)
  String(str: String)
  EOF
}

pub fn to_string(node: Node) -> String {
  node |> to_json |> json.to_string
}

fn to_json(node: Node) -> json.Json {
  case node {
    Let(lhs:, rhs:, body:) ->
      json.object([
        #("lhs", json.string(lhs)),
        #("rhs", to_json(rhs)),
        #("body", to_json(body)),
      ])
    Block(statements:) ->
      json.object([#("statements", json.array(statements, to_json))])
    Function(name:, params:, body:) ->
      json.object([
        #("name", json.string(name)),
        #("params", json.array(params, json.string)),
        #("body", to_json(body)),
      ])
    Identifier(name:) -> json.string(name)
    Integer(num:) -> json.int(num)
    String(str:) -> json.string(str)
    FunctionCall(name:, args:) ->
      json.object([
        #("name", json.string(name)),
        #("args", json.array(args, to_json)),
      ])
    EOF -> json.string("EOF")
  }
}
