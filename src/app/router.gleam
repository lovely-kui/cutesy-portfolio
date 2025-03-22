import views/github_stats/index as github_stats
import views/skill_icons/index as skill_icons
import app/web

import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: web.Context) -> Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  use <- wisp.serve_static(req, under: "/", from: ctx.static_directory)

  case wisp.path_segments(req) {
    ["github-stats", username] -> github_stats.render(req, username)
    ["skill-icons"] -> skill_icons.render(req)
    _ -> wisp.not_found()
  }
}
