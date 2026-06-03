# Repository Guidelines

## Project Structure & Module Organization

This repository stores personal dotfiles for multiple platforms. The active chezmoi source is `chezmoi/`, selected by `.chezmoiroot`. Use it for Windows and cross-platform files such as PowerShell profiles, Git templates, Starship, GlazeWM, Zebar, editor settings, and Rime configuration. The `stow/` tree contains GNU Stow packages; each direct child is a package name, for example `stow/rime/Library/Rime/...`. Root files such as `README.md`, `license`, `.gitignore`, and this guide are repository metadata.

## Build, Test, and Development Commands

There is no compile step. Validate changes by previewing the dotfile manager that will apply them:

- `chezmoi --source . diff`: preview rendered chezmoi changes before applying.
- `chezmoi --source . apply`: apply the current chezmoi source to the local home directory.
- `cd stow && stow -nv -t ~ rime`: dry-run the `rime` Stow package.
- `cd stow && stow -v -t ~ rime`: apply the `rime` Stow package after reviewing the dry run.
- `git status --short`: confirm only intended files changed.

## Coding Style & Naming Conventions

Follow each tool's native format: JSON for editor and terminal settings, YAML for Rime and GlazeWM, TOML for Starship and chezmoi config, and PowerShell for profile scripts. Keep indentation consistent with the edited file, usually two spaces for JSON/YAML/TOML. Chezmoi-managed files use chezmoi names such as `dot_gitconfig.tmpl`, `readonly_Documents/...`, and `AppData/Roaming/...`; preserve these naming patterns so target paths render correctly.

## Testing Guidelines

No automated test suite is configured. For template edits, run `chezmoi --source . diff` and check that rendered paths and values are correct. For JSON files, use an editor or formatter that reports parse errors. For YAML/TOML, keep key ordering stable and avoid unrelated reformatting.

## Commit & Pull Request Guidelines

Recent commits are short and imperative, often scoped when useful, such as `glazewm: update`, `fish: config atuin`, or `feat: update PSReadLine configuration`. Keep commits focused on one tool or platform area. Pull requests should describe the changed dotfiles, list the preview command used, mention affected platforms, and include screenshots only for visible UI changes such as terminal, editor, GlazeWM, or Zebar updates.

## Security & Configuration Tips

Do not commit secrets, machine-local tokens, or private hostnames. Prefer chezmoi templates for values that differ by machine. Review generated diffs carefully before applying changes to your home directory.
