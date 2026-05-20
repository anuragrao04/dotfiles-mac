# dotfiles-mac

Mac dotfiles managed with GNU Stow.

## First setup on a Mac

```bash
brew install stow zsh-syntax-highlighting
git clone git@github.com:anuragrao04/dotfiles-mac.git ~/repos/personal/dotfiles-mac
cd ~/repos/personal/dotfiles-mac
./scripts/bootstrap
```

`bootstrap` backs up conflicting real files into `~/.dotfiles-backup-*`, then stows all packages into `$HOME`.

## Daily two-way sync

Because Stow creates symlinks, editing files in `~` or `~/.config` edits the repo copy.

On the Mac where you changed dotfiles:

```bash
cd ~/repos/personal/dotfiles-mac
git status
git add .
git commit -m "Update dotfiles"
git push
```

On the other Mac:

```bash
cd ~/repos/personal/dotfiles-mac
git pull
./scripts/stow
```

If you create a new dotfile that is not yet stowed, add it to a package manually or update `scripts/sync-from-home`, then commit it.

## Pull current live files into the repo

Useful before the first stow, or for files that are not symlinks yet:

```bash
./scripts/sync-from-home
git diff
```

## Secrets

Secrets are intentionally not committed. `opencode.json` uses environment placeholders for MCP secrets:

- `CONTEXT7_API_KEY`
- `CORALOGIX_MCP_AUTHORIZATION`

This repo assumes those env vars are available on each Mac. One option is your existing `~/tokens/*` loader in `.zshrc`:

```bash
mkdir -p ~/tokens
printf '%s' 'secret-value' > ~/tokens/CONTEXT7_API_KEY
printf '%s' 'secret-value' > ~/tokens/CORALOGIX_MCP_AUTHORIZATION
chmod 700 ~/tokens
chmod 600 ~/tokens/*
```

Do not commit `~/.npmrc`, GitHub `hosts.yml`, cloud credentials, SSH keys, or generated app state.
