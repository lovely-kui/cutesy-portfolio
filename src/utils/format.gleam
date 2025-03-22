import gleam/string
import gleam/int
import gleam/float
import gleam/list

pub type Suffix {
  Suffix(value: Int, unit: String)
}

pub fn number(number: Int) -> String {
  let suffixies: List(Suffix) = [
    Suffix(1_000_000_000, "B"),
    Suffix(1_000_000, "M"),
    Suffix(1_000, "K")
  ]
  // HELPP!!! >_<
  // FUNCTIONAL PROGRAMMING IS SO HARD!!
  // I just wanted to make a
  let suffix = case list.drop_while(suffixies, fn(suffix) { number < suffix.value }) |> list.first {
    Ok(amount) -> amount
    Error(_) -> Suffix(1, "")
  }
  // Oh okie!! I get it now ^-^
  let result = int.to_float(number) /. int.to_float(suffix.value)
  case result |> float.to_string |> string.last {
    Ok("0") -> result |> float.truncate |> int.to_string
    Ok(_) -> result |> float.to_precision(case suffix.unit {
      "K" -> 1
      _   -> 2
    }) |> float.to_string
    Error(_) -> "?" // Do we really need this??
  }
  <>
  suffix.unit
}
