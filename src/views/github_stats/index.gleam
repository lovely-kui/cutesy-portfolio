import gleam/http
import gleam/dict
import gleam/http/request
import gleam/list
import gleam/string
import views/github_stats/fetch
import utils/load
import simplifile as fsys
import wisp.{type Request, type Response}

import gleam/hackney

pub fn url_to_base64(url: String) {
  let assert Ok(request) = request.to(url)
  let assert Ok(response) = request
  |> request.set_method(http.Get)
  |> hackney.send
  response.body
}

pub fn render(request: Request, username) -> Response {
  let assert Ok(path) = fsys.current_directory()
  let path = path<>"/src/views/github_stats/assets/"

  let data = fetch.fetch(username)
  let assert Ok(query) = request.get_query(request)
  let template = case list.key_find(query, "tmplt") {
    Ok(template) if template == "qiwq" || template == "piwp" -> load.utf8(path<>"templates/"<>template<>".html", "Error!!")
    _ -> load.utf8(path<>"templates/qiwq.html", "Error!!")
  }
  let background = case list.key_find(query, "bg") {
    Ok(background) if background == "spacy" -> load.base64(path<>"backgrounds/"<>background<>".jpg", "Error!!")
    _ -> load.base64(path<>"backgrounds/spacy.jpg", "Error!!")
  }
  let decor = case list.key_find(query, "decor") {
    Ok(decor) if decor == "ribbon" -> load.utf8(path<>"decors/"<>decor<>".svg", "Error!!")
    _ -> load.utf8(path<>"decors/ribbon.svg", "Error!!")
  }
  let frame = case list.key_find(query, "frame") {
    Ok(frame) if frame == "kitty" -> load.utf8(path<>"frames/"<>frame<>".svg", "Error!!")
    _ -> load.utf8(path<>"frames/kitty.svg", "Error!!")
  }
  let title_font = case list.key_find(query, "tfont") {
    Ok(font) if font == "copy-duck" || font == "cutie-patootie" -> load.utf8("./src/assets/fonts/"<>font<>".ttf", "Error!!")
    _ -> load.base64("/app/src/assets/fonts/copy-duck.ttf", "Error!!")
  }
  let content_font = case list.key_find(query, "cfont") {
    Ok(font) if font == "copy-duck" || font == "cutie-patootie" -> load.utf8("./src/assets/fonts/"<>font<>".ttf", "Error!!")
    _ -> load.base64("/app/src/assets/fonts/cutie-patootie.ttf", "Error!!")
  }
  let icon = case list.key_find(query, "icon") {
    Ok(icon) if icon == "kitten" -> icon
    _ -> "kitten"
  }
  let title_color = case list.key_find(query, "tcolor") {
    Ok(color) -> color
    Error(_) -> "#70564e"
  }
  let icon_color = case list.key_find(query, "icolor") {
    Ok(color) -> color
    Error(_) -> "#70564e"
  }
  let label_color = case list.key_find(query, "lcolor") {
    Ok(color) -> color
    Error(_) -> "#8a746c"
  }
  let value_color = case list.key_find(query, "vcolor") {
    Ok(color) -> color
    Error(_) -> "#806258"
  }
  let frame_color = case list.key_find(query, "fcolor") {
    Ok(color) -> color
    Error(_) -> "gray"
  }
  let decor_color = case list.key_find(query, "dcolor") {
    Ok(color) -> color
    Error(_) -> "rebeccapurple"
  }
  let decor_pose_x = case list.key_find(query, "dposeX") {
    Ok(pose) -> pose
    Error(_) -> "25%"
  }
  let decor_pose_y = case list.key_find(query, "dposeY") {
    Ok(pose) -> pose
    Error(_) -> "80%"
  }

  let load_icon = fn(name: String) -> String {
    load.utf8(path<>"icons/"<>icon<>"/"<>name<>".svg", "<p>?</p>")
  }

  let template = dict.from_list([
    #("'$user.name'", data.username),
    #("'$user.avatar'", data.avatar_url),
    #("'$user.earned_stars'", data.earned_stars),
    #("'$user.commits'", data.commits),
    #("'$user.pull_requests'", data.pull_requests),
    #("'$user.issues.closed'", data.closed_issues),
    #("'$user.issues.open'", data.open_issues),
    #("'$user.issues.total'", data.total_issues),
    #("'$user.contributes'", data.contributes),
    #("'$icon.star'", load_icon("star")),
    #("'$icon.commit'", load_icon("commit")),
    #("'$icon.pull_request'", load_icon("pull-request")),
    #("'$icon.issue'", load_icon("issue")),
    #("'$icon.repository'", load_icon("repository")),
    #("$background", background),
    #("'$avatar.frame'", frame),
    #("'$avatar.decor'", decor),
    #("'$decor.poseX'", decor_pose_x),
    #("'$decor.poseY'", decor_pose_y),
    #("$font.content", content_font),
    #("$font.title", title_font),
    #("'$color.title'", title_color),
    #("'$color.icon'", icon_color),
    #("'$color.label'", label_color),
    #("'$color.value'", value_color),
    #("'$color.frame'", frame_color),
    #("'$color.decor'", decor_color),
  ]) |> dict.fold(template, fn(acc, key, value) {
    string.replace(acc, key, value)
  })
  wisp.ok()
  |> wisp.set_header("content-type", "image/svg+xml")
  |> wisp.string_body(template)
}
