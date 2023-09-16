#!/bin/bash

DIR=$(realpath "$(dirname "$0")")

source "$DIR/../scripts.sh"

library_key=$(get_library_key "Manual TV")

show_episode_keys () {
  get_show_episode_keys $1 $2 "Manual TV" "Batman the Animated Series" "All episodes"
}

titles () {
  lines_to_base64 "$DIR/titles"
}

summaries () {
  lines_to_base64 "$DIR/summaries"
}

dates () {
  lines_to_base64 "$DIR/dates"
}

paste <(show_episode_keys) <(titles) <(summaries) <(dates) | while read show_episode_key title summary date; do
  update_show_episode_title $library_key $show_episode_key "$title"
  update_show_episode_summary $library_key $show_episode_key "$summary"
  update_show_episode_date $library_key $show_episode_key "$date"
done
