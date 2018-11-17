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

`bin/` files:

```bash
cd $HOME
mkdir bin
cd bin
find ../dotfiles/bin -type f -maxdepth 1 |
  xargs -L 1 -I {} ln -s {}
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

### Global SSH Config

At the top of `~/.ssh/config`:

```
Include "~/.ssh-global-config"
```

### Sublime Text

Sublime Text 3 preferences:

MacOS:

```bash
# stop sublimetext!

cd ~/Library/Application\ Support/Sublime\ Text\ 3/Packages
mv User{,.orig}
ln -s ~/dotfiles/sublime-text/User
```

Arch:

```bash
# stop sublimetext!

cd ~/.config/sublime-text-3/Packages
mv User{,.orig}
ln -s ~/dotfiles/sublime-text/User
```

Once everything is fine, `rm -rf User.orig`.

### MacOS Terminal.app profile

Drag `_terminal_app_profile.terminal` into the Terminal.app's profile list.

### `.coauthors`

`bin/coauthors` reads from `~/.coauthors`, which uses a format of:

```
alice,Alice Foo,alice.foo@example.com
bob,Bob Bar,bob.bar@example.com
```

Then:

```bash
$ coauthors alice
Co-authored-by: Alice Foo <alice.foo@exampe.com>
```
