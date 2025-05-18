#!/bin/bash

function extract_chrome_brave() {
  local input_path=$1
  local output_format=$2  # Pass the output format (csv or tln)

  # Use fd to locate Chrome and Brave browser directories
  browser_dirs=$(fd -t d --glob "**/Default" /mnt/image_mount/Users/*/AppData/Local/*/*/User\ Data)

  if [ -n "$browser_dirs" ]; then
    while read -r dir; do
      browser_type=$(case "$dir" in *Chrome*) echo Chrome ;; *Brave*) echo Brave ;; esac)
      user_name=$(echo "$dir" | cut -d'/' -f5)

      if [ -f "$dir/History" ]; then
        # Extract browsing history
        sqlite3 "$dir/History" "SELECT last_visit_time/1000000-11644473600, url, title, visit_count FROM urls ORDER BY last_visit_time" | \
          awk -F'|' -v browser="$browser_type" -v user="$user_name" -v computer="$comp_name" -v format="$output_format" '
          BEGIN { OFS = (format == "csv" ? "," : "|") }
          {
            timestamp = (format == "csv") ? strftime("%Y-%m-%d %H:%M:%S", $1) : int($1)
            message = "[History] URL:" $2 " TITLE:" $3 " VISIT_COUNT:" $4
            print timestamp, browser, computer, user, message
          }'

        # Extract downloads
        sqlite3 "$dir/History" "SELECT downloads.start_time/1000000-11644473600, downloads.target_path, downloads_url_chains.url FROM downloads INNER JOIN downloads_url_chains ON downloads.id = downloads_url_chains.id ORDER BY downloads.start_time" | \
          awk -F'|' -v browser="$browser_type" -v user="$user_name" -v computer="$comp_name" -v format="$output_format" '
          BEGIN { OFS = (format == "csv" ? "," : "|") }
          {
            timestamp = (format == "csv") ? strftime("%Y-%m-%d %H:%M:%S", $1) : int($1)
            message = "[Download] FILE_PATH:" $2 " URL:" $3
            print timestamp, browser, computer, user, message
          }'
      fi

      if [ -f "$dir/Login Data" ]; then
        # Extract login data
        sqlite3 "$dir/Login Data" "SELECT date_created/1000000-11644473600, origin_url, username_value, signon_realm FROM logins" | \
          awk -F'|' -v browser="$browser_type" -v user="$user_name" -v computer="$comp_name" -v format="$output_format" '
          BEGIN { OFS = (format == "csv" ? "," : "|") }
          {
            timestamp = (format == "csv") ? strftime("%Y-%m-%d %H:%M:%S", $1) : int($1)
            message = "[Login Data] SITE_ORIGIN:" $2 " USER_NAME:" $3 " SIGNON_REALM:" $4
            print timestamp, browser, computer, user, message
          }'
      fi

      if [ -f "$dir/Web Data" ]; then
        # Extract autofill data
        sqlite3 "$dir/Web Data" "SELECT date_last_used/1000000-11644473600, name, value, count, date_created/1000000-11644473600 FROM autofill" | \
          awk -F'|' -v browser="$browser_type" -v user="$user_name" -v computer="$comp_name" -v format="$output_format" '
          BEGIN { OFS = (format == "csv" ? "," : "|") }
          {
            timestamp = (format == "csv") ? strftime("%Y-%m-%d %H:%M:%S", $1) : int($1)
            message = "[WebData] CREATED:" int($5) " NAME:" $2 " VALUE:" $3 " COUNT:" $4
            print timestamp, browser, computer, user, message
          }'
      fi

      if [ -f "$dir/Bookmarks" ]; then
        # Extract bookmarks
        cat "$dir/Bookmarks" | jq -r '.roots[]|recurse(.children[]?)|select(.type != "folder")|{date_added,name,url}|join("|")' | \
          awk -F'|' -v browser="$browser_type" -v user="$user_name" -v computer="$comp_name" -v format="$output_format" '
          BEGIN { OFS = (format == "csv" ? "," : "|") }
          {
            timestamp = (format == "csv") ? strftime("%Y-%m-%d %H:%M:%S", int($1 / 1000000 - 11644473600)) : int($1 / 1000000 - 11644473600)
            message = "[Bookmark Created] NAME:" $2 " URL:" $3
            print timestamp, browser, computer, user, message
          }'
      fi

      if [ -f "$dir/Cookies" ]; then
        # Extract cookies
        sqlite3 "$dir/Cookies" "SELECT creation_utc/1000000-11644473600, host_key, path, name, last_access_utc/1000000-11644473600, value FROM cookies" 2>/dev/null | \
          awk -F'|' -v browser="$browser_type" -v user="$user_name" -v computer="$comp_name" -v format="$output_format" '
          BEGIN { OFS = (format == "csv" ? "," : "|") }
          {
            timestamp = (format == "csv") ? strftime("%Y-%m-%d %H:%M:%S", $1) : int($1)
            message = "[Cookie] HOST:" $2 " PATH:" $3 " NAME:" $4 " LASTACCESS:" strftime("%Y-%m-%d %H:%M:%S", $5) " VALUE:" $6
            print timestamp, browser, computer, user, message
          }'
      fi
    done <<< "$browser_dirs"
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
extract_chrome_brave "$1" "$output_format"
