import gleam/int
import radish
import envoy as env

pub fn connect() {
  let cache_port = case env.get("CACHE_PORT") {
    Ok(cache_port) -> case int.parse(cache_port) {
      Ok(parse) -> parse
      Error(_) -> 6379
    }
    Error(_) -> 6379
  }
  let assert Ok(client) = radish.start("redis", cache_port, [
    radish.Timeout(5000),
    radish.PoolSize(10),
  ])
  client
}

pub fn set(client, key: String, value: String) {
  case radish.set(client, key, value, 86400) {
    Ok(value) -> value
    Error(_) -> "Error"
  }
}

pub fn get(client, key: String) {
  case radish.get(client, key, 3000) {
    Ok(value) -> value
    Error(_) -> "null"
  }
}
