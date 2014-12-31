alias ls='ls -1 -h'
alias server='python2 -m SimpleHTTPServer'
alias histoff="unset HISTFILE"

alias battery_status="upower -i /org/freedesktop/UPower/devices/battery_BAT0"

alias npm-exec='PATH=$(npm bin):$PATH'
alias histoff="unset HISTFILE"
function push-each-commit {
  echo "git fetch && git rebase -i origin/master"
  echo "git rev-list --reverse origin/master..HEAD | xargs -n 1 -I {} bash -c 'git reset --hard {} && git push -f'"
}
