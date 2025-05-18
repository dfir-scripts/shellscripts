#!/bin/bash
# Extract Firefox browsing history, downloads, and cookies
# Supports TLN (default) or CSV output using the -c option

function extract_firefox() {
  local input_path=$1
  local output_format=$2  # Pass the output format (csv or tln)

  # Locate Firefox profile directories
  firefox_dirs=$(find "$input_path" -type d -path "*/AppData/Roaming/Mozilla/Firefox/Profiles/*")

  if [ -n "$firefox_dirs" ]; then
    while read -r dir; do
      browser_type="Firefox"
      # Extract the username from the directory path (e.g., /mnt/Users/JohnDoe -> JohnDoe)
      user_name=$(echo "$dir" | awk -F'/' '{for (i=1; i<=NF; i++) if ($i == "Users") print $(i+1)}')

      if [ -f "$dir/places.sqlite" ]; then
        # Extract browsing history
        sqlite3 "$dir/places.sqlite" "SELECT (moz_historyvisits.visit_date/1000000), moz_places.url, moz_places.title, moz_places.visit_count FROM moz_places, moz_historyvisits WHERE moz_historyvisits.place_id = moz_places.id ORDER BY moz_historyvisits.visit_date" | \
          awk -F'|' -v browser="$browser_type" -v user="$user_name" -v computer="$comp_name" -v format="$output_format" '
          BEGIN { OFS = (format == "csv" ? "," : "|") }
          {
            timestamp = (format == "csv") ? strftime("%Y-%m-%d %H:%M:%S", $1) : int($1)
            message = "[History] URL:" $2 " TITLE:" $3 " VISIT_COUNT:" $4
            print timestamp,browser,computer,user,message
          }'

        # Extract downloads
        sqlite3 "$dir/places.sqlite" "SELECT (dateAdded/1000000) AS dateAdded, url AS Location, moz_anno_attributes.name, content FROM moz_places, moz_annos, moz_anno_attributes WHERE (moz_places.id = moz_annos.place_id) AND (moz_annos.anno_attribute_id = moz_anno_attributes.id)" | \
          awk -F'|' -v browser="$browser_type" -v user="$user_name" -v computer="$comp_name" -v format="$output_format" '
          BEGIN { OFS = (format == "csv" ? "," : "|") }
          {
            timestamp = (format == "csv") ? strftime("%Y-%m-%d %H:%M:%S", $1) : int($1)
            message = "[Download] FILE_PATH:" $2 " NAME:" $3 " CONTENT:" $4
            print timestamp,browser,computer,user,message
          }'
      fi

      if [ -f "$dir/cookies.sqlite" ]; then
        # Extract cookies
        sqlite3 "$dir/cookies.sqlite" "SELECT (creationTime/1000000), host, name, datetime((lastAccessed/1000000),\"unixepoch\",\"utc\"), datetime(expiry,\"unixepoch\",\"utc\") FROM moz_cookies" | \
          awk -F'|' -v browser="$browser_type" -v user="$user_name" -v computer="$comp_name" -v format="$output_format" '
          BEGIN { OFS = (format == "csv" ? "," : "|") }
          {
            timestamp = (format == "csv") ? strftime("%Y-%m-%d %H:%M:%S", $1) : int($1)
            message = "[Cookie] HOST:" $2 " NAME:" $3 " LAST_ACCESS:" $4 " EXPIRY:" $5
            print timestamp,browser,computer,user,message
          }'
      fi

      if [ -f "$dir/places.sqlite" ]; then
        # Extract bookmarks
        sqlite3 "$dir/places.sqlite" "SELECT (moz_bookmarks.dateAdded/1000000), moz_bookmarks.title, moz_places.url FROM moz_bookmarks INNER JOIN moz_places ON moz_bookmarks.fk = moz_places.id WHERE moz_bookmarks.type = 1" | \
          awk -F'|' -v browser="$browser_type" -v user="$user_name" -v computer="$comp_name" -v format="$output_format" '
          BEGIN { OFS = (format == "csv" ? "," : "|") }
          {
            timestamp = (format == "csv") ? strftime("%Y-%m-%d %H:%M:%S", $1) : int($1)
            message = "[Bookmark] TITLE:" $2 " URL:" $3
            print timestamp,browser,computer,user,message
          }'
      fi
    done <<< "$firefox_dirs"
  else
    echo "No Firefox profiles found in $input_path"
  fi
}

# Main script logic
output_format="tln"  # Default output format is TLN

# Parse command-line options
while getopts ":c" opt; do
  case $opt in
    c)
      output_format="csv"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done
shift $((OPTIND - 1))

# Check for required argument
if [ $# -ne 1 ]; then
  echo "Usage: $0 [-c] <path_to_users_or_user_directory>"
  exit 1
fi

# Call the function with the input path and output format
extract_firefox "$1" "$output_format"
