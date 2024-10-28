fn shorthand_label_pattern_arg() {
  case todo {
    Wibble(arg1:, arg2:) -> todo
    //      ^ property
    //              ^ property
  }
}
