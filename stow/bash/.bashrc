# =============================================================================
# bash configuration — managed by GNU Stow
#
# Translated from stow/fish/.config/fish/config.fish (kept in sync by hand).
# Primary target: Debian. Machine-local settings (tokens, private endpoints)
# belong in ~/.bashrc.local and are NOT tracked in this repo.
#
# This file is sourced by BOTH interactive shells and `bash -c` invocations
# (the agent `bash` tool, `pi` shell commands), so keep it fast and never
# block on input.
# =============================================================================

# --- Non-interactive early exit guard -------------------------------------
# Sourced by ~/.bash_profile for login shells (see stow/bash/.bash_profile).
# Nothing below is interactive-only, because the agent `bash` tool runs
# non-interactive `bash -c` and still needs PATH / mise / cargo.

# --- Environment ---
export EDITOR=vim

# English program messages where the locale exists (GPG pinentry otherwise
# follows the system language, e.g. Chinese on macOS; Linux prints warnings
# when LC_MESSAGES names a locale that is not generated)
if locale -a 2>/dev/null | grep -qi '^en_US\.'; then
  export LC_MESSAGES=en_US.UTF-8
fi

# --- PATH ---
# Idempotent prepends: the case guard avoids duplicates in nested shells
# (bash has no fish_add_path; a naive `export PATH=...` re-prepends on every
# re-source and on every inherited PATH from ~/.profile or WSL interop).
__prepend_path() {
  local dir
  for dir in "$@"; do
    [ -d "$dir" ] || continue
    case ":$PATH:" in
      *":$dir:"*) ;;
      *) PATH="$dir:$PATH" ;;
    esac
  done
}

__prepend_path "$HOME/.local/bin"

# --- Rust ---
if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi

# --- bun ---
if [ -x "$HOME/.bun/bin/bun" ]; then
  export BUN_INSTALL="$HOME/.bun"
  __prepend_path "$BUN_INSTALL/bin"
fi

# --- OS-specific setup ---
case "$(uname -s)" in
  Darwin) # macOS
    export PNPM_HOME="$HOME/Library/pnpm"
    __prepend_path "$PNPM_HOME"
    ;;
  Linux)
    # Java: pin JDK 17 when available (Debian installs under /usr/lib/jvm;
    # glob covers amd64/arm64)
    for jvm in /usr/lib/jvm/java-17-openjdk-*; do
      [ -d "$jvm" ] && export JAVA_HOME="$jvm" && break
    done

    # WSL detection for future use
    case "$(uname -r)" in
      *[Mm]icrosoft*) ;; # WSL specific settings
    esac
    ;;
esac

# --- mise (polyglot version manager) ---
# Works in non-interactive shells too, so shims are always available.
# `mise activate bash` detects interactivity itself: it only registers the
# PROMPT_COMMAND hook when the shell is interactive.
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash)"
fi

# --- Interactive session setup ---
if [[ $- == *i* ]]; then
  # GPG: pinentry needs the real terminal; only set when attached to one
  if [ -t 0 ]; then
    export GPG_TTY="$(tty)"
  fi
  if command -v gpg-connect-agent >/dev/null 2>&1; then
    gpg-connect-agent reloadagent /bye >/dev/null 2>&1
  fi

  # Prompt, history, directory jumping
  if command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
  fi
  if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
  fi

  # Shared Python virtualenv (bash has no activate.fish; fall back to the
  # POSIX activate script, then to a plain PATH prepend)
  if [ -f "$HOME/.venv/bin/activate" ]; then
    . "$HOME/.venv/bin/activate"
  elif [ -d "$HOME/.venv/bin" ]; then
    __prepend_path "$HOME/.venv/bin"
  fi

  # Debian ships this tool under a different name
  if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
    alias fd=fdfind
  fi

  # Warp subshell Warpify hook. DCS sequence that signals a ready interactive
  # bash subshell, letting Warp auto-Warpify nested sessions without the
  # confirmation banner. Keep it at the end of this block so Warp does not run
  # its setup script before the rest of this file has been sourced.
  printf '\eP$f{"hook": "SourcedRcFileForWarp", "value": { "shell": "bash"}}\x9c'
fi

# --- Machine-local overrides (untracked) ---
# Tokens, private endpoints, host-only env. Never commit this file.
if [ -f "$HOME/.bashrc.local" ]; then
  . "$HOME/.bashrc.local"
fi

# Helper no longer needed after startup; keep the shell namespace clean.
unset -f __prepend_path
