import gleam/float
import gleam/int
import gleam/dict
import gleam/http/request
import gleam/list
import gleam/string
import gleam/string_tree
import utils/load
import simplifile as fsys
import wisp.{type Request, type Response}

pub fn render(request: Request) -> Response {
  let assert Ok(path) = fsys.current_directory()
  let path = path<>"/src/views/skill_icons/assets/"

  let assert Ok(query) = request.get_query(request)

  let template = load.utf8(path<>"templates/yui.html", "Error!!")
  let icons = case list.key_find(query, "i") {
    Ok(icons) -> string.split(icons, ",")
    _ -> []
  }

  let load_icon = fn(name: String) -> String {
    load.utf8(path<>"icons/"<>name<>".svg", "<p style='margin: 0; padding: 0; font-size: 2.2rem'>?</p>")
  }

  let template = template |> string.replace("'$icons'", string.join(icons, "\n"))
  let template = icons |> list.fold(template, fn(acc, key) {
    string.replace(acc, key, load_icon(key))
  })
  let template = dict.from_list([
    #("'$height'", int.to_string(float.truncate(int.to_float(list.length(icons)) /. 15.) * 50 + 48)),
    #("'$width'", int.to_string(int.subtract(int.min(list.length(icons), 15) * 50, 2)))
  ]) |> dict.fold(template, fn(acc, key, value) {
    string.replace(acc, key, value)
  })
  wisp.html_response(string_tree.from_string(template), 200)
}
