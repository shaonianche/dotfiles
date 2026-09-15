# Global instructions (pi)

## Shell tools

Pick the tool that matches the syntax you are about to write.

- `bash` — available everywhere. Git Bash / MSYS on Windows, `/bin/bash` on Linux
  and macOS. **POSIX syntax only.**
- `powershell` — Windows only (PowerShell 7, started as
  `pwsh -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command`). It does not
  exist on Linux/macOS, so never assume it is there.

### Never mix cmd.exe syntax into the `bash` tool

`ver`, `where`, `del`, `copy`, `dir`, `set`, `2>nul` and `>nul` are cmd.exe
builtins, not POSIX.

- Discard output in bash with `2>/dev/null` or `&>/dev/null`.
- Discard output in PowerShell with `2>$null` or `*>$null`.
- In bash, `>nul` is **not** "discard output" — MSYS treats `nul` as a normal
  filename and creates a real file called `nul`. Use `/dev/null`.

### Route work by dialect, not by habit

- **powershell** — Windows-specific work: registry, services, ACLs, scheduled
  tasks, COM, `AppData` paths, `Get-ChildItem` / `Get-Content` / `Select-String`.
- **bash** — POSIX shell scripts, Makefiles, and anything a repository documents
  as `sh`/`bash`.

`!` and `!!` editor commands always run through Bash, whatever tools are enabled.
