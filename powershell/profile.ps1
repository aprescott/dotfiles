Import-Module $HOME\dotfiles\powershell\prompt.psm1

function g { git @args }
function gs { git status @args }
function gro { git --no-pager log -1 && git fetch && git rebase -i origin/main @args }
# function grb { git --no-pager log -1 && git fetch && git rebase -i $(git merge-base origin/main HEAD) @args }
function gpu { git push -u origin HEAD @args }
function glg { git log-graph @args }
function gl1 { git log -1 --format=fuller @args }
