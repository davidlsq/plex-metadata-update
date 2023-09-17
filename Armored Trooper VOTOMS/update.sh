#!/bin/bash

DIR=$(realpath "$(dirname "$0")")

source "$DIR/../scripts.sh"

TVDB_LOGIN=$(get_tvdb_login $TVDB_TOKEN)
library_key=$(get_library_key "Anime TV")

plex_episodes () {
  get_show_episode_keys "Anime TV" "Armored Trooper VOTOMS" "All episodes"
}

tvdb_episodes () {
  get_tvdb_episodes 90521 eng | grep -v "^0" | cut -d ' ' -f 3-6
}

paste <(plex_episodes) <(tvdb_episodes) | while read show_episode_key poster title date summary; do
  update_show_episode_title $library_key $show_episode_key "$title"
  update_show_episode_date $library_key $show_episode_key "$date"
  update_show_episode_summary $library_key $show_episode_key "$summary"
done
