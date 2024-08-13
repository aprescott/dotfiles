export BASH_SILENCE_DEPRECATION_WARNING=1

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -d ~/etc ]; then
	for f in ~/etc/*.{bash,sh}; do
		# don't run once with f = "~/etc/*.{bash,sh}" if there are no files
		[ -e "$f" ] || continue
		. "$f"
	done
fi

export PATH=~/bin:$PATH
export PATH=/opt/android-sdk/platform-tools:/opt/android-sdk/tools:$PATH
export PATH=/opt/android-ndk:$PATH

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=10000

# The value that would be set for `shell_integration` in `kitty.conf`.
# Specified here because manual integration is in use so we can preserve
# control over PROMPT_COMMAND.
kitty_shell_integration_config_value="no-cursor"
if test -n "$KITTY_INSTALLATION_DIR"; then
    export KITTY_SHELL_INTEGRATION="$kitty_shell_integration_config_value"
    source "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"
fi

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

files_to_source=(
	# arch uses /usr/share for this, which is helpful
	/usr/{,local/}share/chruby/chruby.sh
	/usr/{,local/}share/chruby/auto.sh
	# Latest Apple hardware uses /opt
	/opt/homebrew/opt/chruby/share/chruby/chruby.sh
	/opt/homebrew/opt/chruby/share/chruby/auto.sh
	/usr/local/etc/bash_completion.d/git-prompt.sh
	/usr/local/etc/bash_completion.d/git-completion.bash
	/usr/share/git/completion/git-completion.bash
	/usr/share/git/completion/git-prompt.sh
	# Apple again.
	/opt/homebrew/etc/bash_completion.d/git-completion.bash
	/opt/homebrew/etc/bash_completion.d/git-prompt.sh
)

for f in "${files_to_source[@]}"; do
	if [ -f "$f" ]; then
		source "$f"
	fi
done

if command -v chruby > /dev/null; then
	DEFAULT_RUBY="ruby-3.2.0"
	PWD_RUBY_VERSION="$(cat .ruby-version 2>/dev/null)"

	# If .ruby-version exists in pwd, use that, otherwise use $DEFAULT_RUBY.
	# Useful for, e.g., VS Code terminal initialization
	CHOSEN_RUBY=${PWD_RUBY_VERSION:-$DEFAULT_RUBY}

	chruby "$CHOSEN_RUBY"
fi

# Get npm to put stuff into ~ as "global"
# So I don't have to chown npm's prefix.
NPM_PACKAGES=~/.npm-packages
export PATH=$NPM_PACKAGES/bin:$PATH
unset MANPATH
export MANPATH="$NPM_PACKAGES/share/man:$(manpath)"
export NODE_PATH="$NPM_PACKAGES/lib/node_modules:$NODE_PATH"

interactive_shell=false
if [ -n "$PS1" ]; then
	interactive_shell=true
fi

# Typically, login-specific stuff would go into .(bash_)profile, but we source
# .bashrc there, so we include the login-shell stuff here too.
if $interactive_shell; then
	MAILPATH=/var/spool/mail/$USER'? You have new mail in /var/spool/mail/'$USER

	if [ -f ~/.bash_ps1 ]; then
		. ~/.bash_ps1
	fi
	export PS1

	# ostensibly: pick up .XCompose
	export GTK_IM_MODULE="xim"

	export EDITOR=vim
	export VISUAL=vim
	export GIT_EDITOR=vim
	export SVN_EDITOR=vim

	export LSCOLORS="exfxcxdxbxegedabagacad" # default from man ls
	export LSCOLORS="dxgxcxdxbxegedabagacad"

	# check the window size after each command and, if necessary,
	# update the values of LINES and COLUMNS.
	shopt -s checkwinsize

	# enable programmable completion features (you don't need to enable
	# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
	# sources /etc/bash.bashrc).
	if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
	    . /etc/bash_completion
	fi
fi # end interactive-specifics

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

export FX_THEME=3
. "$HOME/.cargo/env"
