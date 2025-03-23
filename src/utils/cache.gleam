import radish
import envoy as env

pub fn connect() {
  let redis_url = case env.get("REDIS_URL") {
    Ok(redis_url) -> redis_url
    Error(_) -> "redis"
  }
  let assert Ok(client) = radish.start(redis_url, 6379, [
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
