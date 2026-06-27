# file
HISTFILE=~/.zsh_history
# in-shell history
HISTSIZE=10000
# history file
SAVEHIST=10000

WORDCHARS="${WORDCHARS/\/}"
WORDCHARS="${WORDCHARS/-}"
WORDCHARS="${WORDCHARS/_}"
WORDCHARS="${WORDCHARS/:}"

# emacs bindings
bindkey -e

# Shift-Tab for reverse navigation in menu completion.
bindkey '^[[Z' reverse-menu-complete

# Alt-Left and Alt-Right.
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

# Make backward-kill-word-match available.
autoload -U backward-kill-word-match
# Alias backward-kill-word-match, which uses the `word-style` zstyle to
# determine what a word is, which we're going to set to `shell`.
zle -N my-backward-kill-shell-word backward-kill-word-match
zstyle ':zle:my-backward-kill-shell-word' word-style shell
# Bind alt-backspace to the standard C-w.
bindkey '^[^?' backward-kill-word
# Bind C-w to the alias.
bindkey '^W' my-backward-kill-shell-word

# Make path unique to avoid duplicates. Note zsh links $path (array) with $PATH
# (string).
typeset -U path

path=(~/bin $path)
path=("/Applications/Visual Studio Code.app/Contents/Resources/app/bin" $path)

# HISTCONTROL ignoredups equivalent
setopt HIST_IGNORE_DUPS
# HISTCONTROL ignorespace equivalent
setopt HIST_IGNORE_SPACE

# Append incrementally rather than at exit.
setopt INC_APPEND_HISTORY

files_to_source=(
  # Arch uses /usr/share for this
  /usr/{,local/}share/chruby/chruby.sh
  /usr/{,local/}share/chruby/auto.sh
)

if [ ! -z "$HOMEBREW_PREFIX" ]; then
  files_to_source+=(
    "$HOMEBREW_PREFIX/share/chruby/chruby.sh"
    "$HOMEBREW_PREFIX/share/chruby/auto.sh"
    "$HOMEBREW_PREFIX/share/zsh/site-functions/git-prompt.sh"
    "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  )
fi

for f in "${files_to_source[@]}"; do
  if [ -f "$f" ]; then
    source "$f"
  fi
done

if [ -f ~/.zsh_aliases ]; then
  . ~/.zsh_aliases
fi

# if interactive shell
if [[ $- == *i* ]]; then
  if [ -f ~/.zsh_prompt ]; then
    source ~/.zsh_prompt
  fi

  export EDITOR=vim
  export VISUAL="code --wait"
  export GIT_EDITOR="code --wait"

  export LSCOLORS="dxgxcxdxbxegedabagacad"
fi

if command -v fzf > /dev/null; then
  # Set up fzf key bindings and fuzzy completion
  source <(fzf --zsh)
fi

ZSH_AUTOSUGGEST_STRATEGY=(history completion)
bindkey '^ ' autosuggest-accept

# For completion system docs, see
#
#   https://zsh.sourceforge.io/Doc/Release/Completion-System.html
#

# completer config:
#
#   _expand: globs and variables.
#   _complete: normal completion.
#   _ignored: retry completions without ignored configuration like
#             ignored-patterns.
#   _match: pattern-based matching, depending on configuration.
#   _approximate: similar to _complete but allows corrections for typos and
#                 misspellings.
#   _prefix: completion using everything before the cursor, ignoring what's
#            after it.
zstyle ':completion:*' completer _expand _complete _ignored _match _correct _approximate _prefix

# prefix: Expand unambiguous prefixes in a path (such as `/u/i' to `/usr/in',
# which matches both /usr/include and /usr/info) even if the remainder of the
# string on the command line doesn't match any file. So `/u/i/NONEXISTENT'
# expands `u` and `i`.
#
# suffix: allows extra unambiguous parts to be added even after the first
# ambiguous one. So if `/home/p/.pr' would match `/home/pws/.procmailrc' or
# `/home/patricia/.procmailrc', and nothing else, the last word would be
# expanded.
#
# See: https://zsh.sourceforge.io/Guide/zshguide06.html
zstyle ':completion:*' expand prefix suffix

# Display all different types of matches separately by group.
zstyle ':completion:*' group-name ''

# Format for the group type labels
zstyle ':completion:*:descriptions' format $'%{\e[0;33m%}%B%d%b%{\e[0m%}\n'

# Used by _match and _approximate. `true` starts menu completion only if the
# completer could find no unambiguous match.
zstyle ':completion:*' insert-unambiguous true

# dxgxcxdxbxegedabagacad converted with https://geoff.greer.fm/lscolors/
zstyle ':completion:*:default' list-colors 'di=33:ln=36:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'

# Shown when completions overflow the screen.
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s

# Include suffixes in the list of completions, so that multiple prefixes don't
# show, e.g., if `foo/bar` and `foo/baz` are possible paths and we're completing
# on `foo`.
zstyle ':completion:*' list-suffixes true

# Set to any non-empty value other than "only": first try to generate matches
# using the original as-is, then try with `*` at the cursor.
zstyle ':completion:*' match-original both

# The specification list for matches. Tried in order.
#
# Here the ordering is:
#
#   - Match as-is.
#   - Match case-insensitively. (lower -> lower+upper, lower <-> upper)
#   - `r:|[._-]=*` adds `*`` after words separated by [._-].
#   - `r:|=*` appends `*`.
#
# The `+` indicates an attempt using all previous entries in the matcher-list.
zstyle ':completion:*' matcher-list \
  '' \
  'm:{[:lower:]}={[:upper:]} m:{[:lower:][:upper:]}={[:upper:][:lower:]}' \
  'r:|[._-]=* r:|=*' \
  '+r:|[._-]=* r:|=*'

# Maximum number of errors for a completer.
# No correction for short inputs (< 4 chars) to avoid false matches.
zstyle -e ':completion:*' max-errors 'reply=( $(( ${#${PREFIX##*/}} >= 4 ? 2 : 0 )) numeric )'
# Menu completion, with cursor key navigation always enabled.
zstyle ':completion:*' menu select=1

# Include the original input as a possible completion, for _approximate and
# _correct. Lets you get your typo as a valid option if you actually meant it.
zstyle ':completion:*' original true

# Keep `//` followed by any number of non-slash characters. Useful for systems
# where `//` has a special meaning.
zstyle ':completion:*' preserve-prefix '//[^/]##/'

# Shown when the menu selection overflows the screen (different from
# list-prompt, which is for _completions_, not the menu).
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s

# Use the verbose descriptions from completion data. Guarantees more info is
# shown.
zstyle ':completion:*' verbose true

# Lets compinstall re-run against the config file.
# zstyle :compinstall filename ~/.zshrc

zstyle ':completion:*' list-packed false

# completions, `-U` for preventing alias expansion, `-z` for zsh-native
# autoloading.
autoload -Uz compinit
compinit
