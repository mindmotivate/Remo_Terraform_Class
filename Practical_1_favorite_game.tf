variable "favorite_game" {
description = "Favorite_Game"
default = ""
}

resource "local_file" "xbox_games" {
  filename = "${path.module}/favorite-xbox-game.txt"
  content  = "Grand Theft Auto V"
}

output "favorite_xbox_game" {
value = local_file.xbox_games.content
}

resource "local_file" "xbox_html" {
  filename = "${path.module}/index.html"
  content = <<-EOT
  <!DOCTYPE html>
  <html>
  <head>
    <title>${local_file.xbox_games.content}</title>
  </head>
  <body>
    <h1>${local_file.xbox_games.content}</h1>
    <a href="file://./gtav.jpg" target="_blank">
      <img src="./gtav.jpg" alt="Image" width="400">
    </a>
  </body>
  </html>
  EOT
}


output "html_file_path2" {
  value = local_file.xbox_html.filename
}
