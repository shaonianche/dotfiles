# Repository Guidelines

## Project Structure & Module Organization

This repository stores personal dotfiles for multiple platforms.

- **Windows:** chezmoi. The active source is `chezmoi/`, selected by `.chezmoiroot`. Use it for PowerShell profiles, Git templates, Komorebi, editor settings, and Windows-only paths such as `AppData/` and `readonly_Documents/`.
- **macOS & Linux (including Debian/WSL):** GNU Stow. The `stow/` tree contains packages; each direct child is a package name, for example `stow/bash/`, `stow/fish/`, `stow/git/`, `stow/starship/`, or `stow/rime/Library/Rime/...`. Apply `stowrc` first so later packages pick up the repo `.stowrc`.

The full package inventory under `stow/`:

- `bash/` → `.bashrc`, `.bash_profile` (login shell on macOS/Linux; translated from `fish/`)
- `curl/` → `.curlrc`
- `emacs/` → `.emacs.d/init.el`
- `fish/` → `.config/fish/config.fish`, `.config/fish/functions/fish_prompt.fish`, `.hushlogin` (legacy interactive shell; kept in sync with `bash/`)
- `git/` → `.gitattributes`, `.gitconfig`, `.gitignore`
- `gnupg/` → `.gnupg/gpg.conf`, `.gnupg/gpg-agent.conf`
- `input/` → `.inputrc`
- `pi/` → `.pi/agent/` (the pi config, shared cross-platform — see below)
- `rime/` → `Library/Rime/` (Rime input-method custom YAML)
- `starship/` → `.config/starship.toml`
- `stowrc/` → the repo's own `.stowrc` (bootstrap package)
- `tmux/` → `.tmux.conf`
- `vim/` → `.vimrc`
- `wget/` → `.wgetrc`
- `zed/` → `.config/zed/settings.json`, `.config/zed/keymap.json`

Root files such as `README.md`, `license`, `.gitignore`, and this guide are repository metadata.

### Shared Cross-Platform Configuration

For configuration shared between Windows and macOS/Linux, keep the file under `stow/` as the single source of truth. Have the corresponding chezmoi `.tmpl` file include that Stow file rather than maintaining a duplicate copy or linking Stow back to `chezmoi/`. Edit the Stow source when updating shared configuration; keep platform-specific settings separate.

For example, `chezmoi/dot_pi/agent/models.json.tmpl` reads `stow/pi/.pi/agent/models.json`:

```gotemplate
{{ include "../stow/pi/.pi/agent/models.json" -}}
```

The include path is relative to the chezmoi source directory (`chezmoi/`), not the template's directory. The trailing `-` avoids adding an extra newline after the included content.

### Bash (macOS / Linux, default login shell)

Tracked files live in `stow/bash/`. Bash is the login shell on this machine and the shell used by the pi `bash` tool, which runs non-interactive `bash -c` (no config file is read by default) — so `~/.bashrc` is deliberately written to be safe for both interactive and non-interactive use.

- `.bashrc` — shared setup; env, PATH, mise, and interactive-only blocks guarded by `[[ $- == *i* ]]`
- `.bash_profile` — login shells read this (not `.bashrc`); it sources `~/.bashrc` then `~/.profile`

Machine-local settings (tokens, private endpoints, host-only env) belong in `~/.bashrc.local`, which `~/.bashrc` sources at the end if present and which must **not** be committed. The `1password.fish` and `cf.fish` equivalents currently live there.

macOS ships bash 3.2 at `/bin/bash`, which lacks `declare -A`, `mapfile`, and `&>>`. A current bash 5.3 is built from GNU source to `/opt/local/bin/bash` (per the global `--prefix=/opt/local` rule) and registered in `/etc/shells`; the login shell and `shellPath` both point at it.

### Fish (Linux / Debian / WSL)

`stow/fish/` is kept as a legacy interactive-shell config and is **translated by hand** into `stow/bash/.bashrc` — when changing shell setup, update both files.

Tracked files live in `stow/fish/`:

- `.config/fish/config.fish` — shared setup; tool inits are guarded with `command -q`
- `.config/fish/functions/fish_prompt.fish` — fallback prompt when Starship is absent
- `.hushlogin` — suppress the Debian/WSL login MOTD

Machine-local settings (tokens, private endpoints, host-only env) belong in `~/.config/fish/conf.d/*.fish` and must **not** be committed. Stow only manages the files above; existing `conf.d/`, `fish_plugins`, and Fisher functions stay on the machine.

## Build, Test, and Development Commands

There is no compile step. Validate changes by previewing the manager that will apply them:

- `chezmoi --source . diff`: preview rendered chezmoi changes before applying.
- `chezmoi --source . apply`: apply the current chezmoi source to the local home directory.
- `cd stow && stow -nv -t ~ stowrc`: dry-run the bootstrap Stow package.
- `cd stow && stow -nv -t ~ bash`: dry-run the `bash` package (same pattern for `fish`, `git`, `starship`, `rime`, …).
- `cd stow && stow -v -t ~ bash`: apply after reviewing the dry run.
- `/opt/local/bin/bash -n stow/bash/.bashrc`: syntax-check the bash config (`-n` = no-execute parse only).
- `fish -n stow/fish/.config/fish/config.fish`: syntax-check the fish config.
- `git status --short`: confirm only intended files changed.

If `~/.bashrc` or `~/.bash_profile` already exists as a regular file, move it aside before the first `stow bash`. The same applies to `~/.config/fish/config.fish` and `stow fish`.

## Coding Style & Naming Conventions

Follow each tool's native format: JSON for editor and terminal settings, YAML for Rime, TOML for Starship and chezmoi config, Bash for `.bashrc`/`.bash_profile`, Fish for `config.fish`, and PowerShell for profile scripts. Keep indentation consistent with the edited file, usually two spaces for JSON/YAML/TOML. Chezmoi-managed files use chezmoi names such as `dot_gitconfig.tmpl`, `readonly_Documents/...`, and `AppData/Roaming/...`; preserve these naming patterns so target paths render correctly.

## Testing Guidelines

No automated test suite is configured. For template edits, run `chezmoi --source . diff` and check that rendered paths and values are correct. For bash edits, run `/opt/local/bin/bash -n` and verify both a non-interactive (`bash -c`) and a login (`bash -lc`) invocation work, since the pi `bash` tool and terminal sessions exercise different startup files. For fish edits, run `fish -n` and confirm guarded `command -q` blocks still skip missing tools. For JSON files, use an editor or formatter that reports parse errors. For YAML/TOML, keep key ordering stable and avoid unrelated reformatting.

## Commit & Pull Request Guidelines

Recent commits are short and imperative, often scoped when useful, such as `glazewm: update`, `fish: config atuin`, or `feat: update PSReadLine configuration`. Keep commits focused on one tool or platform area. Pull requests should describe the changed dotfiles, list the preview command used, mention affected platforms, and include screenshots only for visible UI changes such as terminal, editor, or Komorebi updates.

## Security & Configuration Tips

Do not commit secrets, machine-local tokens, or private hostnames. Prefer chezmoi templates for values that differ by machine on Windows. On Linux/macOS, keep those values in untracked files such as `~/.bashrc.local` (sourced by `stow/bash/.bashrc`) and `~/.config/fish/conf.d/*.fish`. Review generated diffs carefully before applying changes to your home directory.
