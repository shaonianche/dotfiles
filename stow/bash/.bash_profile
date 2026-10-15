# =============================================================================
# bash login-shell configuration — managed by GNU Stow
#
# macOS Terminal.app / iTerm / Ghostty start login shells, which read
# ~/.bash_profile (NOT ~/.bashrc). Debian reads ~/.bash_profile too, then falls
# back to ~/.profile. Source ~/.bashrc so login and non-login shells share one
# configuration.
#
# Guard: only source once. On macOS, Terminals spawn login shells; on WSL/GUI
# logins ~/.profile may also be read — the guard prevents double sourcing.
# =============================================================================

# Source the shared ~/.bashrc (guarded against double sourcing)
if [ -f "$HOME/.bashrc" ]; then
  . "$HOME/.bashrc"
fi

# Source ~/.profile for values exported by the login session (cargo, etc.).
# Skipped on macOS because stock macOS terminals do not create ~/.profile;
# keeping it here is harmless thanks to the -f guard.
if [ -f "$HOME/.profile" ]; then
  . "$HOME/.profile"
fi
