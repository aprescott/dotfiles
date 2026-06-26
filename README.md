## Initial setup

Home dotfile symlinking:

```bash
cd $HOME
find dotfiles -type f -maxdepth 1 |
  grep -v '^dotfiles/_' |
  grep -v '^dotfiles/vs-code-' |
  grep -v README.md |
  grep -v .gitignore |
  grep -v .global.gitconfig |
  xargs -L 1 -I {} ln -f -s {}

mkdir -p .vim/{backups,swapfiles}

ln -s ../dotfiles/nvim .config/nvim

mkdir -p .emacs.d/backups
mkdir -p .emacs.d/auto-saves
mkdir -p .emacs.d/lock-files
ln -s ../dotfiles/.emacs.d/init.el .emacs.d/init.el
```

`bin/` files:

```bash
cd $HOME
mkdir bin
cd bin
find ../dotfiles/bin -type f -maxdepth 1 |
  xargs -L 1 -I {} ln -s {}
```

Claude:

```bash
cd $HOME
cd .claude
ln -s ../dotfiles/claude/statusline-command.sh statusline-command.sh
```

kitty terminal config:

```shell
cd $HOME
cd .config/kitty
find ../../dotfiles/kitty -type f -maxdepth 1 |
  xargs -L 1 -I {} ln -f -s {}
```

kitty custom icon (macOS):

```shell
cd $HOME
cd .config/kitty

# See https://sw.kovidgoyal.net/kitty/faq/#i-do-not-like-the-kitty-icon
wget "https://github.com/k0nserv/kitty-icon/raw/refs/tags/2023-07-09/build/neue_outrun.icns"
ln -s neue_outrun.icns kitty.app.icns

# Restart kitty.
# If necessary:
rm /var/folders/*/*/*/com.apple.dock.iconcache; killall Dock
```

To undo:

- Open the kitty app in Finder.
- Cmd-I to open the app's info panel.
- Click the app icon in the top left of the info panel.
- Hit backspace to remove the custom icon.
- Restart kitty and wipe the Dock icon cache if necessary.

## [WIP] Initial setup (Windows, Powershell)

In `$PROFILE`:

```powershell
$custom = "$HOME\dotfiles\powershell\profile.ps1"

if (Test-Path $custom) {
    . $custom
}
```

```powershell
cp $env:APPDATA/Code/User/keybindings.json $env:APPDATA/Code/User/keybindings.json.original
New-Item -ItemType SymbolicLink -Path $env:APPDATA/Code/User/keybindings.json -Target C:/Users/USERNAME/dotfiles/vs-code-user-keybindings.json

cp $env:APPDATA/Code/User/settings.json $env:APPDATA/Code/User/settings.json.original
New-Item -ItemType SymbolicLink -Path $env:APPDATA/Code/User/settings.json -Target C:/Users/USERNAME/dotfiles/vs-code-user-settings.json
```

### Git config

`~/.gitconfig`:

```ini
[include]
  path=~/dotfiles/.global.gitconfig

# Any other non-global, overriding settings below
```

Example useful conditional config:

```ini
[includeIf "gitdir:~/code/"]
  path = ~/.work.gitconfig
```

Then, e.g., in `~/.work.gitconfig`:

```ini
[user]
  email = you@work.example.com
```

### Global SSH Config

At the top of `~/.ssh/config`:

```ssh-config
Include "~/dotfiles/ssh/ssh_config"
```

### VS Code

```bash
cd ~/Library/Application\ Support/Code/User
mv settings.json{,.orig}
ln -s ~/dotfiles/vs-code-user-settings.json settings.json
ln -s ~/dotfiles/vs-code-user-keybindings.json keybindings.json
ln -s ~/dotfiles/vs-code-user-tasks.json tasks.json
```

Once everything is fine, `rm` the `.orig` files.

Install extensions using the list in `vs-code-extensions`:

```bash
cat vs-code-extensions | xargs -n 1 -I {} code --install-extension {}
```

Snapshot extensions with `code --list-extensions --show-versions > ~/dotfiles/vs-code-extensions`.

### Homebrew

After installation, Homebrew will prompt you to add its own setup `eval` line to `~/.bash_profile`.

Add it instead to `~/etc`:

```bash
mkdir ~/etc
touch ~/etc/homebrew.sh
# add the eval line to `~/etc/homebrew.sh`
```

On macOS, `brew install git` to make sure you're not on Apple's built-in `git`.

### macOS Terminal.app profile

Drag `_terminal_app_profile.terminal` into the Terminal.app's profile list. (Set it as default in the profile list.)

Upgrade bash:

```bash
brew install bash
# confirm `which -a bash` shows /opt/homebrew/bin/bash above /bin/bash
sudo vim /etc/shells # add /opt/homebrew/bin/bash
chsh -s /opt/homebrew/bin/bash
# echo "$BASH_VERSION" to confirm
```

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

# Claude config

`~/.claude/settings.json` needs a `CLAUDE_ENV_FILE` config:

```json
"env": {
  "CLAUDE_ENV_FILE": "/path/to/claude_env.sh"
}
```

Where `claude_env.sh` contains:

```bash
source ~/.bashrc
```

Without it, automatic Ruby switching won't work, for reasons I don't fully understand. Probably the lack of env var persistence across commands. https://code.claude.com/docs/en/tools-reference#bash-tool-behavior says:

> Environment variables do not persist. An `export` in one command will not be available in the next.
