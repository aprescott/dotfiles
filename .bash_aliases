alias ls='ls -1 -h'
alias histoff="unset HISTFILE"

alias npm-exec='PATH=$(npm bin):$PATH'

function push-each-commit {
  git rev-list --reverse origin/master..HEAD | xargs -n 1 -I {} git log -1 --oneline {}
  echo
  echo "git fetch && git rebase -i origin/master"
  echo "git rev-list --reverse origin/master..HEAD | xargs -n 1 -I {} bash -c 'git reset --hard {} && git push -f'"
}

alias fundle='bundle check || bundle install --jobs=10 --local'

alias gro="git fetch && git rebase -i origin/master"
alias gpu="git push -u origin HEAD"
