![powershell](https://raw.githubusercontent.com/shaonianche/gallery/master/img/powershell.png)
Dotfiles
-----

My simple and uniform dotfiles for Windows, macOS, and Linux.

### Windows

chezmoi: https://www.chezmoi.io/quick-start/

```powershell
chezmoi init
```
### macOS & Linux

Default shell is bash 5.3 (`/opt/local/bin/bash`, built from GNU source).

```bash
cd stow && stow -v -t ~ stowrc
cd stow && stow -v -t ~ bash
```

Package order matters: `stowrc` first (bootstrap), then the rest. See `AGENTS.md` for the full package list.
