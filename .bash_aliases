alias ls='ls -la -h'
alias histoff="unset HISTFILE"

alias npm-exec='PATH=$(npm bin):$PATH'

function push-each-commit {
  git rev-list --reverse origin/main..HEAD | xargs -n 1 -I {} git log -1 --oneline {}
  echo
  echo "git fetch && git rebase -i origin/main"
  echo "git rev-list --reverse origin/main..HEAD | xargs -n 1 -I {} bash -c 'git reset --hard {} && git push -f'"
}

alias fundle='bundle check || bundle install --jobs=10 --local'

alias gro="git --no-pager log -1 && git fetch && git rebase -i origin/main"
alias gpu="git push -u origin HEAD"

function untilfail() {
  while "$@"; do :; done
}

function untilsuccess() {
  while ! "$@"; do :; done
}

alias mrc="git log -1 --format=fuller"
alias icat="kitten icat"
alias rg="rg --hidden"
