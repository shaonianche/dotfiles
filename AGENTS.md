# Repository Guidelines

## Project Structure & Module Organization

This repository stores personal dotfiles for multiple platforms.

- **Windows:** chezmoi. The active source is `chezmoi/`, selected by `.chezmoiroot`. Use it for PowerShell profiles, Git templates, GlazeWM, Zebar, editor settings, and Windows-only paths such as `AppData/`, `readonly_Documents/`, and `dot_glzr/`.
- **macOS & Linux (including Debian/WSL):** GNU Stow. The `stow/` tree contains packages; each direct child is a package name, for example `stow/fish/`, `stow/git/`, `stow/starship/`, or `stow/rime/Library/Rime/...`. Apply `stowrc` first so later packages pick up the repo `.stowrc`.

Root files such as `README.md`, `license`, `.gitignore`, and this guide are repository metadata.

### Fish (Linux / Debian / WSL)

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
- `cd stow && stow -nv -t ~ fish`: dry-run the `fish` package (same pattern for `git`, `starship`, `rime`, …).
- `cd stow && stow -v -t ~ fish`: apply after reviewing the dry run.
- `fish -n stow/fish/.config/fish/config.fish`: syntax-check the fish config.
- `git status --short`: confirm only intended files changed.

If `~/.config/fish/config.fish` already exists as a regular file, move it aside before the first `stow fish`.

## Coding Style & Naming Conventions

Follow each tool's native format: JSON for editor and terminal settings, YAML for Rime and GlazeWM, TOML for Starship and chezmoi config, Fish for `config.fish`, and PowerShell for profile scripts. Keep indentation consistent with the edited file, usually two spaces for JSON/YAML/TOML. Chezmoi-managed files use chezmoi names such as `dot_gitconfig.tmpl`, `readonly_Documents/...`, and `AppData/Roaming/...`; preserve these naming patterns so target paths render correctly.

## Testing Guidelines

No automated test suite is configured. For template edits, run `chezmoi --source . diff` and check that rendered paths and values are correct. For fish edits, run `fish -n` and confirm guarded `command -q` blocks still skip missing tools. For JSON files, use an editor or formatter that reports parse errors. For YAML/TOML, keep key ordering stable and avoid unrelated reformatting.

## Commit & Pull Request Guidelines

Recent commits are short and imperative, often scoped when useful, such as `glazewm: update`, `fish: config atuin`, or `feat: update PSReadLine configuration`. Keep commits focused on one tool or platform area. Pull requests should describe the changed dotfiles, list the preview command used, mention affected platforms, and include screenshots only for visible UI changes such as terminal, editor, GlazeWM, or Zebar updates.

## Security & Configuration Tips

Do not commit secrets, machine-local tokens, or private hostnames. Prefer chezmoi templates for values that differ by machine on Windows. On Linux/macOS, keep those values in untracked files such as `~/.config/fish/conf.d/*.fish`. Review generated diffs carefully before applying changes to your home directory.
