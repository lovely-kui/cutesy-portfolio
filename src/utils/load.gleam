import gleam/bit_array
import simplifile as fsys

pub fn base64(path: String, error: String) -> String {
  case fsys.read_bits(path) {
    Ok(bits) -> bit_array.base64_encode(bits, True)
    Error(_) -> error
  }
}
pub fn utf8(path: String, error: String) -> String {
  case fsys.read(path) {
    Ok(bits) -> bits
    Error(_) -> error
  }
}
