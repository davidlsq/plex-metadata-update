get_library_key () {
  curl -s "http://$HOST/library/sections?X-Plex-Token=$PLEX_TOKEN" | \
    xmlstarlet sel -t -v "/MediaContainer/Directory[@title=\"$1\"]/@key"
}

get_library_keys () {
  curl -s "http://$HOST/library/sections?X-Plex-Token=$PLEX_TOKEN" | \
    xmlstarlet sel -t -v "/MediaContainer/Directory/@key"
}

get_show_key () {
  library_key=$(get_library_key "$1")
  curl -s "http://$HOST/library/sections/$library_key/all?X-Plex-Token=$PLEX_TOKEN" | \
    xmlstarlet sel -t -v "/MediaContainer/Directory[@title=\"$2\"]/@key"
}

get_show_keys() {
  library_key=$(get_library_key "$1")
  curl -s "http://$HOST/library/sections/$library_key/all?X-Plex-Token=$PLEX_TOKEN" | \
    xmlstarlet sel -t -v "/MediaContainer/Directory/@key"
}

get_show_season_key () {
  show_key=$(get_show_key "$1" "$2")
  curl -s "http://$HOST$show_key?X-Plex-Token=$PLEX_TOKEN" | \
    xmlstarlet sel -t -v "/MediaContainer/Directory[@title=\"$3\"]/@key"
}

get_show_season_keys() {
  show_key=$(get_show_key "$1" "$2")
  curl -s "http://$HOST$show_key?X-Plex-Token=$PLEX_TOKEN" | \
    xmlstarlet sel -t -v "/MediaContainer/Directory/@key"
}

get_show_episode_key () {
  show_season_key=$(get_show_season_key "$1" "$2" "$3")
  curl -s "http://$HOST$show_season_key?X-Plex-Token=$PLEX_TOKEN" | \
    xmlstarlet sel -t -v "/MediaContainer/Video[@title=\"$4\"]/@key"
}

get_show_episode_keys () {
  show_season_key=$(get_show_season_key "$1" "$2" "$3")
  curl -s "http://$HOST$show_season_key?X-Plex-Token=$PLEX_TOKEN" | \
    xmlstarlet sel -t -v "/MediaContainer/Video/@key"
}

update_show_episode_title () {
  id=$(echo "$2" | cut -d '/' -f 4)
  title=$(printf %s "$3" | base64 -d | jq -sRr @uri)
  curl -X PUT -s "http://$HOST/library/sections/$1/all?id=$id&title.value=$title&title.locked=1&type=4&X-Plex-Token=$PLEX_TOKEN"
}

update_show_episode_summary () {
  id=$(echo "$2" | cut -d '/' -f 4)
  summary=$(printf %s "$3" | base64 -d | jq -sRr @uri)
  curl -X PUT -s "http://$HOST/library/sections/$1/all?id=$id&summary.value=$summary&summary.locked=1&type=4&X-Plex-Token=$PLEX_TOKEN"
}

update_show_episode_date () {
  id=$(echo "$2" | cut -d '/' -f 4)
  date=$(printf %s "$3" | base64 -d | jq -sRr @uri)
  curl -X PUT -s "http://$HOST/library/sections/$1/all?id=$id&originallyAvailableAt.value=$date&originallyAvailableAt.locked=1&type=4&X-Plex-Token=$PLEX_TOKEN"
}

lines_to_base64 () {
  while IFS= read -r line; do printf %s "$line" | base64; done < "$1"
}

get_tvdb_login () {
  curl -X POST -s "https://api4.thetvdb.com/v4/login" --header "Content-Type: application/json" --data "{\"apikey\":\"$TVDB_TOKEN\"}" | \
    jq -r '.data.token'
}

search_tvdb_series () {
  name=$(printf %s "$1" | jq -sRr @uri)
  curl -s "https://api4.thetvdb.com/v4/search?query=$name" --header "Authorization: Bearer $TVDB_LOGIN" | \
    jq -r '.data | map([.name, .id] | join("\t")) | join("\n")'
}

get_tvdb_episodes () {
  curl -s "https://api4.thetvdb.com/v4/series/$1/episodes/default/$2" --header "Authorization: Bearer $TVDB_LOGIN" | \
    jq -r '.data.episodes | map([.seasonNumber, .number, (.name | @base64), (.aired | @base64), (.overview | @base64)] | join(" ")) | join("\n")'
}
