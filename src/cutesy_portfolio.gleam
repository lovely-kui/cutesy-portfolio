// Why am i need to import everythingy??
// It looks ugly!! T-T
import gleam/int
import app/router
import app/web.{Context}
import gleam/erlang/process
import mist
import wisp
import wisp/wisp_mist
import simplifile as fsys
import dotenv_gleam
import envoy as env

pub fn main() {
  dotenv_gleam.config()
  let log_level = case env.get("LOG_LEVEL") {
    Ok("alert") -> wisp.AlertLevel
    Ok("critical") -> wisp.CriticalLevel
    Ok("debug") -> wisp.DebugLevel
    Ok("emergency") -> wisp.EmergencyLevel
    Ok("error") -> wisp.ErrorLevel
    Ok("info") -> wisp.InfoLevel
    Ok("notice") -> wisp.NoticeLevel
    Ok("warning") -> wisp.WarningLevel
    _ -> wisp.InfoLevel
  }
  let assert Ok(api_port) = env.get("API_PORT")
  wisp.configure_logger()
  wisp.set_logger_level(log_level)
  let secret_key_base = wisp.random_string(64)
  let ctx = Context(static_directory: static_directory())
  let handler = router.handle_request(_, ctx)

  let assert Ok(_) =
    wisp_mist.handler(handler, secret_key_base)
    |> mist.new
    |> mist.bind("0.0.0.0")
    |> mist.port(case int.parse(api_port) {
      Ok(api_port) -> api_port
      Error(_) -> 8000
    })
    |> mist.start_http
  process.sleep_forever()
}

pub fn static_directory() -> String {
  let assert Ok(path) = fsys.current_directory()
  path<>"/public"
}
