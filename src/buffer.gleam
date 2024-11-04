//// A collection of helper functions for dealing with indices and positions in
//// the buffer. All indices are 0-based, and all positions are (0, 0)-based.

import gleam/list

pub type Index =
  Int

pub type Position =
  #(Int, Int)

pub fn index_to_position(
  index index: Index,
  in buffer: List(String),
) -> Position {
  let buf = buffer |> list.take(index)
  let line_num = buf |> list.filter(fn(char) { char == "\n" }) |> list.length
  let column =
    buf
    |> list.reverse
    |> list.take_while(fn(char) { char != "\n" })
    |> list.length
    |> fn(len) { len - 1 }
  #(line_num, column)
}
