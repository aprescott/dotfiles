Home dotfiles:

```bash
cd $HOME
find dotfiles -type f -maxdepth 1 |
  grep -v '^dotfiles/_' |
  grep -v README.md |
  grep -v .gitignore |
  xargs -L 1 -I {} ln -f -s {}
```

Git config:

```
[include]
	path=~/.gitconfig-global

# Any other non-global, overriding settings below
```

SublimeText 2 preferences:

Arch:

```bash
# stop sublimetext!

cd ~/.config/sublime-text-2/Packages
mv User{,.orig}
ln -s ~/dotfiles/sublime-text/User
```

OS X:

```bash
# stop sublimetext!

cd ~/Library/Application\ Support/Sublime\ Text\ 2/Packages
mv User{,.orig}
ln -s ~/dotfiles/sublime-text/User
```
