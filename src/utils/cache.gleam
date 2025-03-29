import gleam/io
import gleam/int
import radish
import envoy as env

pub fn connect() {
  let redis_host = case env.get("REDIS_HOST") {
    Ok(redis_host) -> redis_host
    Error(_) -> "redis"
  }
  let redis_port = case env.get("REDIS_PORT") {
    Ok(redis_port) -> case int.parse(redis_port) {
      Ok(redis_port) -> redis_port
      Error(_) -> 6379
    }
    Error(_) -> 6379
  }
  let redis_password = case env.get("REDIS_PASSWORD") {
    Ok(redis_password) -> redis_password
    Error(_) -> "cookie1235" // Ofc it's secure!! Everyone would try "1234" haha :3
  }
  let assert Ok(client) = radish.start(redis_host, redis_port, [
    radish.Timeout(5000),
    radish.PoolSize(10),
    radish.Auth(redis_password)
  ])
  io.debug(client)
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
