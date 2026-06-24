#!/usr/bin/env bash

input=$(cat)

# To debug and test, comment the below, then:
#
#   cat /tmp/claude-status.json | path/to/script.sh
#

# echo "$input" > /tmp/claude-status.json

model=$(echo "$input" | jq -r '.model.display_name // empty')
effort=$(echo "$input" | jq -r '.effort.level // empty')
ctx_used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_hour=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# Unix epoch seconds
five_hour_resets_at=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
seven_day_resets_at=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

five_hour_resets_at_fmt=$(date -r "$five_hour_resets_at" '+%H:%M' 2>/dev/null)
weekly_resets_at_fmt=$(date -r "$seven_day_resets_at" '+%a %H:%M' 2>/dev/null)

worktree_name=$(echo "$input" | jq -r '.worktree.name // empty')
worktree_branch=$(echo "$input" | jq -r '.worktree.branch // empty')
worktree_original_branch=$(echo "$input" | jq -r '.worktree.original_branch // empty')

RESET="\033[00m"
GRAY="\033[0;90m"
ORANGE="\033[38;5;215m"
WHITE="\033[37m"

color_for_percent() {
  local pct=$1

  if (( $(bc -l <<< "$pct < 50") )); then
    printf '\033[38;5;34m'  # green
  elif (( $(bc -l <<< "$pct < 70") )); then
    printf '\033[38;5;70m'  # yellow-green
  elif (( $(bc -l <<< "$pct < 85") )); then
    printf '\033[38;5;178m' # yellow
  elif (( $(bc -l <<< "$pct < 95") )); then
    printf '\033[38;5;208m' # orange
  else
    printf '\033[38;5;196m' # red
  fi
}

color_for_delta() {
  local delta=$1

  if (( $(bc -l <<< "$delta >= 20") )); then
    printf '\033[38;5;196m'  # red (way over)
  elif (( $(bc -l <<< "$delta >= 15") )); then
    printf '\033[38;5;208m'  # orange
  elif (( $(bc -l <<< "$delta >= 10") )); then
    printf '\033[38;5;208m'  # orange
  elif (( $(bc -l <<< "$delta >= 5") )); then
    printf '\033[38;5;178m'  # yellow (slightly over)
  elif (( $(bc -l <<< "$delta >= 0") )); then
    printf '\033[38;5;178m'  # yellow (on quota)
  elif (( $(bc -l <<< "$delta >= -5") )); then
    printf '\033[38;5;178m'  # yellow (slightly under)
  elif (( $(bc -l <<< "$delta >= -10") )); then
    printf '\033[38;5;70m'  # yellow-green
  elif (( $(bc -l <<< "$delta >= -15") )); then
    printf '\033[38;5;70m'  # yellow-green
  elif (( $(bc -l <<< "$delta >= -20") )); then
    printf '\033[38;5;34m'  # green
  else
    printf '\033[38;5;34m'  # green (way under)
  fi
}

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

parts=()

if [ -n "$five_hour" ]; then
  pct=$(printf '%.1f' "$five_hour")
  expected_fmt=$(printf '%.1f' "$expected_5h_pct")
  pct_delta_fmt=$(printf '%.1f' "$pct_delta_5h")
  sign_5h=""
  if (( $(bc -l <<< "$pct_delta_5h >= 0") )); then
    sign_5h="+"
  fi
  parts+=("${WHITE}5h${RESET} $(color_for_percent "$five_hour")${pct}%${RESET} (${expected_fmt}%, $(color_for_delta "$pct_delta_5h")${sign_5h}${pct_delta_fmt}%${RESET}, ⟲ ${five_hour_resets_at_fmt})")
fi

if [ -n "$seven_day" ]; then
  pct=$(printf '%.1f' "$seven_day")
  expected_fmt=$(printf '%.1f' "$expected_weekly_pct")
  pct_delta_fmt=$(printf '%.1f' "$pct_delta_weekly")
  sign_weekly=""
  if (( $(bc -l <<< "$pct_delta_weekly >= 0") )); then
    sign_weekly="+"
  fi
  parts+=("${WHITE}Week${RESET} $(color_for_percent "$seven_day")${pct}%${RESET} (${expected_fmt}%, $(color_for_delta "$pct_delta_weekly")${sign_weekly}${pct_delta_fmt}%${RESET}, ⟲ ${weekly_resets_at_fmt})")
fi

if [ -n "$ctx_used" ]; then
  pct=$(printf '%.1f' "$ctx_used")
  parts+=("${GRAY}Context $(color_for_percent "$ctx_used")${pct}%${RESET}")
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
