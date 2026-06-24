#!/usr/bin/env bash

set -euo pipefail

now=$(date +%s)
script_path="$(dirname "$0")/statusline-command.sh"

test_case() {
  local label=$1
  local five_h_offset=$2
  local weekly_offset=$3

  local five_h_reset=$((now + five_h_offset))
  local weekly_reset=$((now + weekly_offset))

  echo "========================================"
  echo "$label"
  echo "========================================"

  cat <<EOF | $script_path | sed 's/\x1b\[[0-9;]*m//g'
{
  "model": {"display_name": "Sonnet 4.6"},
  "effort": {"level": "medium"},
  "context_window": {"used_percentage": 41.0},
  "rate_limits": {
    "five_hour": {"used_percentage": 46, "resets_at": $five_h_reset},
    "seven_day": {"used_percentage": 20, "resets_at": $weekly_reset}
  },
  "worktree": {"name": "foo-bar-baz", "branch": "worktree-foo-bar-baz", "original_branch": "main"}
}
EOF
  echo ""
}

test_case "Example 1: 45m / 5d 10h" \
  $((45 * 60)) \
  $((5 * 86400 + 10 * 3600))

test_case "Example 2: 1h 30m / 7d 0h" \
  $((1 * 3600 + 30 * 60)) \
  $((7 * 86400))

test_case "Example 3: 4h 45m / 1d 5h" \
  $((4 * 3600 + 45 * 60)) \
  $((1 * 86400 + 5 * 3600))

test_case "Example 4: 4h 59m / 5d 10h" \
  $((4 * 3600 + 59 * 60)) \
  $((5 * 86400 + 10 * 3600))

test_case "Example 5: 1m / 2d 10h" \
  $((1 * 60)) \
  $((2 * 86400 + 10 * 3600))

# Example 6: test 100% used (window just reset or is resetting)
now=$(date +%s)
five_h_reset=$now
weekly_reset=$now

echo "========================================"
echo "Example 6: 0m / 0m (100% used, at reset)"
echo "========================================"
cat <<EOF | "$(dirname "$0")/statusline-command.sh" | sed 's/\x1b\[[0-9;]*m//g'
{
  "model": {"display_name": "Sonnet 4.6"},
  "effort": {"level": "medium"},
  "context_window": {"used_percentage": 41.0},
  "rate_limits": {
    "five_hour": {"used_percentage": 100, "resets_at": $five_h_reset},
    "seven_day": {"used_percentage": 100, "resets_at": $weekly_reset}
  },
  "worktree": {"name": "foo-bar-baz", "branch": "worktree-foo-bar-baz", "original_branch": "main"}
}
EOF
echo ""

# Example 7: test 0% used but 100% predicted (window just reset)
now=$(date +%s)
five_h_reset=$now
weekly_reset=$now

echo "========================================"
echo "Example 7: 0m / 0m (0% used, 100% expected)"
echo "========================================"
cat <<EOF | "$(dirname "$0")/statusline-command.sh" | sed 's/\x1b\[[0-9;]*m//g'
{
  "model": {"display_name": "Sonnet 4.6"},
  "effort": {"level": "medium"},
  "context_window": {"used_percentage": 41.0},
  "rate_limits": {
    "five_hour": {"used_percentage": 0, "resets_at": $five_h_reset},
    "seven_day": {"used_percentage": 0, "resets_at": $weekly_reset}
  },
  "worktree": {"name": "foo-bar-baz", "branch": "worktree-foo-bar-baz", "original_branch": "main"}
}
EOF
echo ""
