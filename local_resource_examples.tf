#Resource block examples:

resource "local_file" "games"{
filename = "${path.module}/favorite-games.txt"
content = "FIFA 21"
}

resource "local_file" "movies"{
filename = "${path.module}/favorite-movie.txt"
content = "Higher_Learning"
}

resource "local_file" "countries"{
filename = "${path.module}/favorite-country.txt"
content = "Costa-Rica"
}

resource "local_file" "cloud_providers"{
filename = "${path.module}/favorite-provider.txt"
content = "AWS"
}

