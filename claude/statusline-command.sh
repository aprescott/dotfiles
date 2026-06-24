#!/usr/bin/env bash

input=$(cat)

# To debug and test, comment the below, then:
#
#   cat /tmp/claude-status.json | path/to/script.sh
#

# echo "$input" > /tmp/claude-status.json

# Helper functions
color_for_percent() {
  local pct=$1
  if (( $(bc -l <<< "$pct < 50") )); then printf '\033[38;5;34m'
  elif (( $(bc -l <<< "$pct < 70") )); then printf '\033[38;5;70m'
  elif (( $(bc -l <<< "$pct < 85") )); then printf '\033[38;5;178m'
  elif (( $(bc -l <<< "$pct < 95") )); then printf '\033[38;5;208m'
  else printf '\033[38;5;196m'; fi
}

color_for_delta() {
  local delta=$1
  if (( $(bc -l <<< "$delta >= 20") )); then printf '\033[38;5;196m'
  elif (( $(bc -l <<< "$delta >= 15") )); then printf '\033[38;5;208m'
  elif (( $(bc -l <<< "$delta >= 10") )); then printf '\033[38;5;208m'
  elif (( $(bc -l <<< "$delta >= 5") )); then printf '\033[38;5;178m'
  elif (( $(bc -l <<< "$delta >= 0") )); then printf '\033[38;5;178m'
  elif (( $(bc -l <<< "$delta >= -5") )); then printf '\033[38;5;178m'
  elif (( $(bc -l <<< "$delta >= -10") )); then printf '\033[38;5;70m'
  elif (( $(bc -l <<< "$delta >= -15") )); then printf '\033[38;5;70m'
  elif (( $(bc -l <<< "$delta >= -20") )); then printf '\033[38;5;34m'
  else printf '\033[38;5;34m'; fi
}

right_align_array() {
  local -n arr=$1
  local max_len=0 i
  for i in "${arr[@]}"; do [[ ${#i} -gt $max_len ]] && max_len=${#i}; done
  for i in "${!arr[@]}"; do arr[$i]=$(printf "%${max_len}s" "${arr[$i]}"); done
}

# Format a number to specified decimal places
format_number() {
  local val=$1 precision=$2
  printf "%.${precision}f" "$val"
}

# Pad string to width (right-aligned)
pad_to_width() {
  local val=$1 width=$2
  printf "%${width}s" "$val"
}

# Determine sign from number and return it
get_sign() {
  local val=$1
  [[ "$val" == -* ]] && echo "-" || echo "+"
}

# Strip sign from number string
strip_sign() {
  local val=$1
  [[ "$val" == -* ]] && echo "${val#-}" || echo "$val"
}

# Trim leading space if present
ltrim_space() {
  local val=$1
  [[ "$val" == " "* ]] && val="${val# }"
  echo "$val"
}

model=$(echo "$input" | jq -r '.model.display_name // empty')
effort=$(echo "$input" | jq -r '.effort.level // empty')
ctx_used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_hour=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# Unix epoch seconds
five_hour_resets_at=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
seven_day_resets_at=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

format_remaining_time() {
  local resets_at=$1
  local max_day_width=$2
  local max_part1_width=$3
  local max_part2_width=$4

  local now_secs=$(date +%s)
  local remaining_secs=$((resets_at - now_secs))

  if (( remaining_secs < 0 )); then
    echo "reset"
    return
  fi

  local days=$((remaining_secs / 86400))
  local hours=$(((remaining_secs % 86400) / 3600))
  local minutes=$(((remaining_secs % 3600) / 60))

  if (( days > 0 )); then
    days=$(pad_to_width "$days" "$max_day_width")
    hours=$(pad_to_width "$hours" "$max_part2_width")
    hours=$(ltrim_space "$hours")
    echo "${days}d ${hours}h"
  elif (( hours > 0 )); then
    hours=$(pad_to_width "$hours" "$max_part1_width")
    minutes=$(pad_to_width "$minutes" "$max_part2_width")
    minutes=$(ltrim_space "$minutes")
    echo "${hours}h ${minutes}m"
  else
    minutes=$(pad_to_width "$minutes" "$max_part2_width")
    echo "${minutes}m"
  fi
}

# Calculate component widths for both reset times
now_secs=$(date +%s)
rem_5h=$((five_hour_resets_at - now_secs))
rem_weekly=$((seven_day_resets_at - now_secs))

days_5h=0 hours_5h=0 mins_5h=0
if (( rem_5h > 0 )); then
  days_5h=$((rem_5h / 86400))
  hours_5h=$(((rem_5h % 86400) / 3600))
  mins_5h=$(((rem_5h % 3600) / 60))
fi

days_weekly=0 hours_weekly=0 mins_weekly=0
if (( rem_weekly > 0 )); then
  days_weekly=$((rem_weekly / 86400))
  hours_weekly=$(((rem_weekly % 86400) / 3600))
  mins_weekly=$(((rem_weekly % 3600) / 60))
fi

# Find max widths
max_day_width=${#days_5h}
[[ ${#days_weekly} -gt $max_day_width ]] && max_day_width=${#days_weekly}
max_part1_width=${#hours_5h}
[[ ${#hours_weekly} -gt $max_part1_width ]] && max_part1_width=${#hours_weekly}
max_part2_width=${#mins_5h}
[[ ${#mins_weekly} -gt $max_part2_width ]] && max_part2_width=${#mins_weekly}

five_hour_resets_at_fmt=$(format_remaining_time "$five_hour_resets_at" "$max_day_width" "$max_part1_width" "$max_part2_width")
weekly_resets_at_fmt=$(format_remaining_time "$seven_day_resets_at" "$max_day_width" "$max_part1_width" "$max_part2_width")

# Right-align reset times
reset_times=("$five_hour_resets_at_fmt" "$weekly_resets_at_fmt")
right_align_array reset_times
five_hour_resets_at_fmt="${reset_times[0]}"
weekly_resets_at_fmt="${reset_times[1]}"

worktree_name=$(echo "$input" | jq -r '.worktree.name // empty')
worktree_branch=$(echo "$input" | jq -r '.worktree.branch // empty')
worktree_original_branch=$(echo "$input" | jq -r '.worktree.original_branch // empty')

RESET="\033[00m"
GRAY="\033[0;90m"
ORANGE="\033[38;5;215m"
WHITE="\033[37m"

# Given the remaining time until the 5-hour limit resets, calculate the expected
# percentage of usage as if we had used a uniform amount over the entire window,
# so that we can then know if we're over or under.
expected_5h_percentage_based_on_remaining_time() {
  local endsAtSecs=$1
  local nowSecs=$(date +%s)
  local remainingSecs=$((endsAtSecs - nowSecs))
  # The 5-hour window is 18,000 seconds long.
  bc -l <<< "100 - ($remainingSecs * 100 / 18000)"
}

expected_weekly_percentage_based_on_remaining_time() {
  local endsAtSecs=$1
  local nowSecs=$(date +%s)
  local remainingSecs=$((endsAtSecs - nowSecs))
  # The weekly window is 604,800 seconds long.
  bc -l <<< "100 - ($remainingSecs * 100 / 604800)"
}

expected_5h_pct=$(expected_5h_percentage_based_on_remaining_time "$five_hour_resets_at")
expected_weekly_pct=$(expected_weekly_percentage_based_on_remaining_time "$seven_day_resets_at")

pct_delta_5h=$(bc -l <<< "$five_hour - $expected_5h_pct")
pct_delta_weekly=$(bc -l <<< "$seven_day - $expected_weekly_pct")

# Format numeric parts and determine signs
numeric_5h=$(format_number "$pct_delta_5h" 1)
numeric_weekly=$(format_number "$pct_delta_weekly" 1)

sign_5h=$(get_sign "$numeric_5h")
numeric_5h=$(strip_sign "$numeric_5h")

sign_weekly=$(get_sign "$numeric_weekly")
numeric_weekly=$(strip_sign "$numeric_weekly")

# Pad numeric parts to same width
max_numeric_len=${#numeric_5h}
[[ ${#numeric_weekly} -gt $max_numeric_len ]] && max_numeric_len=${#numeric_weekly}
numeric_5h=$(pad_to_width "$numeric_5h" "$max_numeric_len")
numeric_weekly=$(pad_to_width "$numeric_weekly" "$max_numeric_len")

# Create delta strings with sign, space, and padded numeric
delta_str_5h="${sign_5h} ${numeric_5h}%"
delta_str_weekly="${sign_weekly} ${numeric_weekly}%"

parts=()

# Calculate and pad percentages to same width
pct_5h=$(format_number "$five_hour" 0)
pct_weekly=$(format_number "$seven_day" 0)
max_pct_len=${#pct_5h}
[[ ${#pct_weekly} -gt $max_pct_len ]] && max_pct_len=${#pct_weekly}
pct_5h=$(pad_to_width "$pct_5h" "$max_pct_len")
pct_weekly=$(pad_to_width "$pct_weekly" "$max_pct_len")

if [ -n "$five_hour" ]; then
  expected_fmt=$(format_number "$expected_5h_pct" 1)
  line_5h="${WHITE}  5h${GRAY}  $(color_for_percent "$five_hour")${pct_5h}%${GRAY}  ${RESET}⟲ ${five_hour_resets_at_fmt}${GRAY}  (${expected_fmt}%, $(color_for_delta "$pct_delta_5h")${delta_str_5h}${GRAY})"
  if [ -n "$worktree_name" ]; then
    line_5h+="   ${GRAY}Worktree: ${worktree_name}${RESET}"
  fi
  parts+=("$line_5h")
fi

if [ -n "$seven_day" ]; then
  expected_fmt=$(format_number "$expected_weekly_pct" 1)
  line_weekly="${WHITE}Week${GRAY}  $(color_for_percent "$seven_day")${pct_weekly}%${GRAY}  ${RESET}⟲ ${weekly_resets_at_fmt}${GRAY}  (${expected_fmt}%, $(color_for_delta "$pct_delta_weekly")${delta_str_weekly}${GRAY})"
  if [ -n "$worktree_branch" ]; then
    line_weekly+="   ${GRAY}Branch:   ${worktree_branch}"
    if [ -n "$worktree_original_branch" ]; then
      line_weekly+=" (from ${worktree_original_branch})"
    fi
    line_weekly+="${RESET}"
  fi
  parts+=("$line_weekly")
fi

output=""
separator="${GRAY} · ${RESET}"

# Build top line: model, context, effort
top_parts=()
if [ -n "$model" ]; then
  top_parts+=("${GRAY}${model}${RESET}")
fi

if [ -n "$ctx_used" ]; then
  pct=$(format_number "$ctx_used" 1)
  top_parts+=("${GRAY}Context $(color_for_percent "$ctx_used")${pct}%${RESET}")
fi

if [ -n "$effort" ]; then
  top_parts+=("${GRAY}(${effort})${RESET}")
fi

for part in "${top_parts[@]}"; do
  if [ -n "$output" ]; then
    output+="$separator"
  fi
  output+="$part"
done

# Add newline before rate limits
if [ -n "$output" ]; then
  output+=$'\n'
fi

# Add rate limit sections
for part in "${parts[@]}"; do
  if [[ "$part" == *"Week"* ]]; then
    output+=$'\n'
  fi

  if [[ "$output" != *$'\n' ]] && [ -n "$output" ]; then
    output+="$separator"
  fi
  output+="$part"
done

printf '%b' "$output"
