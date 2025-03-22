import gleam/dict
import gleam/dynamic/decode
import gleam/hackney
import gleam/http
import gleam/http/request
import gleam/json
import gleam/list
import simplifile as fsys
import utils/cache
import utils/format
import envoy as env

pub type Stats {
  Stats(
    username: String,
    avatar_url: String,
    earned_stars: String,
    commits: String,
    pull_requests: String,
    open_issues: String,
    closed_issues: String,
    total_issues: String,
    contributes: String,
  )
}

pub fn fetch(username: String) -> Stats {
  let assert Ok(path) = fsys.current_directory()
  let path = path<>"/src/views/github_stats/"

  let cache = cache.connect()
  case cache.get(cache, "github-stats/" <> username) {
    data if data == "null" -> {
      let assert Ok(request) = request.to("https://api.github.com/graphql")
      let assert Ok(graphql) = fsys.read(path <> "schema.gql")
      let assert Ok(github_token) = env.get("GITHUB_TOKEN1")
      let assert Ok(response) = request
      |> request.set_method(http.Post)
      |> request.prepend_header("Content-Type", "application/json")
      |> request.prepend_header("Authorization", "bearer "<>github_token)
      |> request.set_body(
        json.object([
          #("query", json.string(graphql)),
          #("variables", json.object([
            #("username", json.string(username)),
            #("from", json.string("2025-12-31T23:59:59Z")),
            #("to", json.string("2025-12-31T23:59:59Z")),
          ]))
        ])
        |> json.to_string,
      )
      |> hackney.send
      cache.set(cache, "github-stats/" <> username, response.body)
      response.body
    }
    data -> data
  }
  |> decode_json
}

fn decode_json(json_string: String) -> Stats {
  let decoder = {
    use username <- decode.subfield(
      ["data", "user", "name"],
      decode.string
    )
    use avatar_url <- decode.subfield(
      ["data", "user", "avatarUrl"],
      decode.string,
    )
    use earned_stars <- decode.subfield(
      ["data", "user", "repositories", "nodes"],
      decode.list(decode.dict(
        decode.string,
        decode.dict(decode.string, decode.int),
      )),
    )
    use commits <- decode.subfield(
      ["data", "user", "contributionsCollection", "totalCommitContributions"],
      decode.int
    )
    use pull_requests <- decode.subfield(
      ["data", "user", "pullRequests", "totalCount"],
      decode.int
    )
    use open_issues <- decode.subfield(
      ["data", "user", "openIssues", "totalCount"],
      decode.int
    )
    use closed_issues <- decode.subfield(
      ["data", "user", "closedIssues", "totalCount"],
      decode.int
    )
    use contributes <- decode.subfield(
      ["data", "user", "repositoriesContributedTo", "totalCount"],
      decode.int
    )
    decode.success(Stats(
      username: username,
      avatar_url: avatar_url,
      earned_stars: case list.map(earned_stars, fn(repo) {
        let assert Ok(stargazers) = dict.get(repo, "stargazers")
        let assert Ok(total_count) = dict.get(stargazers, "totalCount")
        total_count
      }) |> list.reduce(fn(acc, x) { acc + x }) {
        Ok(total_star) -> total_star
        Error(_) -> 0
      } |> format.number,
      commits: format.number(commits),
      pull_requests: format.number(pull_requests),
      open_issues: format.number(open_issues),
      closed_issues: format.number(closed_issues),
      total_issues: format.number(open_issues + closed_issues),
      contributes: format.number(contributes),
    ))
  }
  case json.parse(from: json_string, using: decoder) {
    Ok(result) -> result
    Error(_) -> Stats("Unknown", "https://cdnl.iconscout.com/lottie/premium/thumb/question-mark-4876768-4105703.gif", "?", "?", "?", "?", "?", "?", "?")
  }
}
