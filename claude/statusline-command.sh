#!/usr/bin/env bash

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // empty')
effort=$(echo "$input" | jq -r '.effort.level // empty')
ctx_used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_hour=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

RESET="\033[00m"
GRAY="\033[0;90m"
ORANGE="\033[38;5;215m"

color_for_percent() {
  local pct=$1

  if (( pct < 50 )); then
    printf '\033[38;5;34m'  # green
  elif (( pct < 70 )); then
    printf '\033[38;5;70m'  # yellow-green
  elif (( pct < 85 )); then
    printf '\033[38;5;178m' # yellow
  elif (( pct < 95 )); then
    printf '\033[38;5;208m' # orange
  else
    printf '\033[38;5;196m' # red
  fi
}

parts=()

if [ -n "$five_hour" ]; then
  pct=$(printf '%.0f' "$five_hour")
  parts+=("${GRAY}5h $(color_for_percent "$pct")${pct}%${RESET}")
fi

if [ -n "$seven_day" ]; then
  pct=$(printf '%.0f' "$seven_day")
  parts+=("${GRAY}Week $(color_for_percent "$pct")${pct}%${RESET}")
fi

if [ -n "$ctx_used" ]; then
  pct=$(printf '%.0f' "$ctx_used")
  parts+=("${GRAY}Context $(color_for_percent "$pct")${pct}%${RESET}")
fi

if [ -n "$model" ]; then
  parts+=("${GRAY}${model}${RESET}")
fi

if [ -n "$effort" ]; then
  parts+=("${GRAY}(${effort})${RESET}")
fi

output=""
separator="${GRAY} · ${RESET}"

for part in "${parts[@]}"; do
  if [ -n "$output" ]; then
    output+="$separator"
  fi
  output+="$part"
done

printf '%b' "$output"
