#!/usr/bin/env bash

input=$(cat)

RESET="\033[00m"
GRAY="\033[0;90m"
WHITE="\033[37m"

GREEN="\033[38;5;34m"
YELLOW="\033[38;5;178m"
YELLOW_ORANGE="\033[38;5;208m"
RED="\033[38;5;196m"

# To debug and test, comment the below, then:
#
#   cat /tmp/claude-status.json | path/to/script.sh
#

echo "$input" > /tmp/claude-status.json

# Helper functions
color_for_percent() {
  local pct=$1
  if (( $(bc -l <<< "$pct < 50") )); then printf "${GRAY}"
  elif (( $(bc -l <<< "$pct < 70") )); then printf "${YELLOW}"
  elif (( $(bc -l <<< "$pct < 85") )); then printf "${YELLOW_ORANGE}"
  elif (( $(bc -l <<< "$pct < 95") )); then printf "${YELLOW_ORANGE}"
  else printf "${RED}"; fi
}

color_for_delta() {
  local delta=$1
  if (( $(bc -l <<< "$delta >= 20") )); then printf "${RED}"
  elif (( $(bc -l <<< "$delta >= 15") )); then printf "${YELLOW_ORANGE}"
  elif (( $(bc -l <<< "$delta >= 10") )); then printf "${YELLOW_ORANGE}"
  elif (( $(bc -l <<< "$delta >= 5") )); then printf "${YELLOW}"
  elif (( $(bc -l <<< "$delta >= 0") )); then printf "${YELLOW}"
  elif (( $(bc -l <<< "$delta >= -5") )); then printf "${YELLOW}"
  else printf "${GRAY}"; fi
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

format_duration_secs() {
  local secs=$1 max_last_width=$2
  local days=$(( secs / 86400 ))
  local hours=$(( (secs % 86400) / 3600 ))
  local minutes=$(( (secs % 3600) / 60 ))
  if (( days > 0 )); then
    echo "${days}d $(pad_to_width "$hours" "$max_last_width")h"
  elif (( hours > 0 )); then
    echo "${hours}h $(pad_to_width "$minutes" "$max_last_width")m"
  else
    echo "$(pad_to_width "$minutes" "$max_last_width")m"
  fi
}

format_remaining_time() {
  local resets_at=$1 max_last_width=$2
  local now_secs=$(date +%s)
  local remaining_secs=$(( resets_at - now_secs ))
  if (( remaining_secs < 0 )); then
    echo "reset"
    return
  fi
  format_duration_secs "$remaining_secs" "$max_last_width"
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

# Find the rightmost numeric component for each time to align across format tiers.
# "Xd Yh" format → last = Y (hours); "Xh Ym" or "Ym" format → last = Y or m (minutes).
if (( rem_5h > 0 )); then
  [[ $days_5h -gt 0 ]] && last_num_5h=$hours_5h || last_num_5h=$mins_5h
else
  last_num_5h=0
fi

if (( rem_weekly > 0 )); then
  [[ $days_weekly -gt 0 ]] && last_num_weekly=$hours_weekly || last_num_weekly=$mins_weekly
else
  last_num_weekly=0
fi

max_last_width=${#last_num_5h}
[[ ${#last_num_weekly} -gt $max_last_width ]] && max_last_width=${#last_num_weekly}

five_hour_resets_at_fmt=$(format_remaining_time "$five_hour_resets_at" "$max_last_width")
weekly_resets_at_fmt=$(format_remaining_time "$seven_day_resets_at" "$max_last_width")

# Right-align reset times
reset_times=("$five_hour_resets_at_fmt" "$weekly_resets_at_fmt")
right_align_array reset_times
five_hour_resets_at_fmt="${reset_times[0]}"
weekly_resets_at_fmt="${reset_times[1]}"

worktree_name=$(echo "$input" | jq -r '.worktree.name // empty')
worktree_branch=$(echo "$input" | jq -r '.worktree.branch // empty')
worktree_original_branch=$(echo "$input" | jq -r '.worktree.original_branch // empty')

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

# Break-even: seconds until the window catches up to actual usage.
# Positive = over budget (hits 100% before reset); negative = under budget.
be_5h_secs_raw=$(bc -l <<< "$five_hour_resets_at - 18000 * (100 - $five_hour) / 100 - $now_secs")
be_weekly_secs_raw=$(bc -l <<< "$seven_day_resets_at - 604800 * (100 - $seven_day) / 100 - $now_secs")

if (( $(bc -l <<< "$be_5h_secs_raw >= 0") )); then
  be_5h_sign="+"
  be_5h_secs=${be_5h_secs_raw%.*}
else
  be_5h_sign="-"
  abs="${be_5h_secs_raw#-}"
  be_5h_secs=${abs%.*}
  be_5h_secs=${be_5h_secs:-0}
fi

if (( $(bc -l <<< "$be_weekly_secs_raw >= 0") )); then
  be_weekly_sign="+"
  be_weekly_secs=${be_weekly_secs_raw%.*}
else
  be_weekly_sign="-"
  abs="${be_weekly_secs_raw#-}"
  be_weekly_secs=${abs%.*}
  be_weekly_secs=${be_weekly_secs:-0}
fi

# Determine last numeric component of each b.e. duration for alignment
be_5h_d=$(( be_5h_secs / 86400 ))
be_5h_h=$(( (be_5h_secs % 86400) / 3600 ))
be_5h_m=$(( (be_5h_secs % 3600) / 60 ))
[[ $be_5h_d -gt 0 ]] && last_be_5h=$be_5h_h || last_be_5h=$be_5h_m

be_wk_d=$(( be_weekly_secs / 86400 ))
be_wk_h=$(( (be_weekly_secs % 86400) / 3600 ))
be_wk_m=$(( (be_weekly_secs % 3600) / 60 ))
[[ $be_wk_d -gt 0 ]] && last_be_weekly=$be_wk_h || last_be_weekly=$be_wk_m

max_be_last_width=${#last_be_5h}
[[ ${#last_be_weekly} -gt $max_be_last_width ]] && max_be_last_width=${#last_be_weekly}

be_5h_dur=$(format_duration_secs "$be_5h_secs" "$max_be_last_width")
be_weekly_dur=$(format_duration_secs "$be_weekly_secs" "$max_be_last_width")

be_durs=("$be_5h_dur" "$be_weekly_dur")
right_align_array be_durs
be_5h_dur="${be_durs[0]}"
be_weekly_dur="${be_durs[1]}"

be_5h_suffix=", b.e. ${be_5h_sign} ${be_5h_dur}"
be_weekly_suffix=", b.e. ${be_weekly_sign} ${be_weekly_dur}"

be_5h_pad="" be_weekly_pad=""

parts=()

# Calculate and pad percentages to same width
pct_5h=$(format_number "$five_hour" 0)
pct_weekly=$(format_number "$seven_day" 0)
max_pct_len=${#pct_5h}
[[ ${#pct_weekly} -gt $max_pct_len ]] && max_pct_len=${#pct_weekly}
pct_5h=$(pad_to_width "$pct_5h" "$max_pct_len")
pct_weekly=$(pad_to_width "$pct_weekly" "$max_pct_len")

# Format and pad expected percentages to same width
expected_5h_fmt=$(format_number "$expected_5h_pct" 1)
expected_weekly_fmt=$(format_number "$expected_weekly_pct" 1)
max_expected_len=${#expected_5h_fmt}
[[ ${#expected_weekly_fmt} -gt $max_expected_len ]] && max_expected_len=${#expected_weekly_fmt}
expected_5h_fmt=$(pad_to_width "$expected_5h_fmt" "$max_expected_len")
expected_weekly_fmt=$(pad_to_width "$expected_weekly_fmt" "$max_expected_len")

if [ -n "$five_hour" ]; then
  line_5h="${WHITE}  5h${GRAY}  $(color_for_percent "$five_hour")${pct_5h}%${RESET}  ${GRAY}⟲${RESET} ${five_hour_resets_at_fmt}${GRAY}  ${expected_5h_fmt}%, $(color_for_delta "$pct_delta_5h")${delta_str_5h}${GRAY}${be_5h_suffix}${be_5h_pad}"
  if [ -n "$worktree_name" ]; then
    line_5h+="   ${GRAY}Worktree: ${worktree_name}${RESET}"
  fi
  parts+=("$line_5h")
fi

if [ -n "$seven_day" ]; then
  line_weekly="${WHITE}Week${GRAY}  $(color_for_percent "$seven_day")${pct_weekly}%${RESET}  ${GRAY}⟲${RESET} ${weekly_resets_at_fmt}${GRAY}  ${expected_weekly_fmt}%, $(color_for_delta "$pct_delta_weekly")${delta_str_weekly}${GRAY}${be_weekly_suffix}${be_weekly_pad}"
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

function effort_color() {
  local effort_level=$1
  case "$effort_level" in
    low) echo "${RESET}" ;;
    medium) echo "${YELLOW}" ;;
    high) echo "${YELLOW_ORANGE}" ;;
    *) echo "${RED}" ;;
  esac
}

# Build top line: model, context, effort
top_parts=()
if [ -n "$model" ]; then
  model_str="${GRAY}${model}${RESET}"

  if [ -n "$effort" ]; then
    model_str+=" ${GRAY}($(effort_color "$effort")${effort}${GRAY})${RESET}"
  fi

  top_parts+=("$model_str")
fi

if [ -n "$ctx_used" ]; then
  pct=$(format_number "$ctx_used" 1)
  top_parts+=("${GRAY}Context $(color_for_percent "$ctx_used")${pct}%${RESET}")
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
