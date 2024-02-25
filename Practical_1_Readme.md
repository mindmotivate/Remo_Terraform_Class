## #Favorite Xbox Game Example:

This Terraform code defines a variable named "favorite_game" to hold the user's favorite game. It then creates two local file resources:

- Variable Block: 
  - Defines a variable named "favorite_game" with a description "Favorite_Game" and an empty default value.

- Resource Block (xbox_games): 
  - Defines a local file resource named "favorite-xbox-game.txt" with the content "Grand Theft Auto V".

- Resource Block (xbox_html): 
  - Defines a local file resource named "index.html" with HTML content including a title, heading, and an image linked to "gtav.jpg".

Output:
- favorite_xbox_game: 
  - Displays the content of the "favorite-xbox-game.txt" file.
- html_file_path2: 
  - Displays the filename of the "index.html" file.
 


