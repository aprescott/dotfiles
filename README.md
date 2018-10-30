## Initial setup

Home dotfiles:

```bash
cd $HOME
find dotfiles -type f -maxdepth 1 |
  grep -v '^dotfiles/_' |
  grep -v README.md |
  grep -v .gitignore |
  xargs -L 1 -I {} ln -f -s {}

mkdir -p .vim
cp -R dotfiles/.vim/{autoload,backups} .vim/
```

### Git config

`~/.gitconfig`:

```
[include]
	path=~/.gitconfig-global

# Any other non-global, overriding settings below
```

Useful conditional config:

```
[includeIf "gitdir:~/code/"]
    path = ~/.gitconfig-work
```

Then, e.g., in `~/.gitconfig-work`:

```
[user]
    email = you@work.example.com
```

### `~/.ssh/config`

SSH starting config (until [`.ssh/config` supports config includes](https://bugzilla.mindrot.org/show_bug.cgi?id=1585))

```
ServerAliveCountMax 15
ServerAliveInterval 3
UseRoaming No
```

### Sublime Text

Sublime Text 3 preferences:

Arch:

```bash
# stop sublimetext!

cd ~/.config/sublime-text-3/Packages
mv User{,.orig}
ln -s ~/dotfiles/sublime-text/User
```

OS X:

```bash
# stop sublimetext!

cd ~/Library/Application\ Support/Sublime\ Text\ 3/Packages
mv User{,.orig}
ln -s ~/dotfiles/sublime-text/User
```

Once everything is fine, `rm -rf User.orig`.
