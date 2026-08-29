# =============================================================================
# fish configuration — managed by GNU Stow
# Primary target: Debian. Machine-local settings (tokens, private endpoints)
# belong in ~/.config/fish/conf.d/*.fish and are NOT tracked in this repo.
# =============================================================================

# --- Environment ---
set -gx EDITOR vim
# English program messages where the locale exists (GPG pinentry otherwise
# follows the system language, e.g. Chinese on macOS; Linux prints warnings
# when LC_MESSAGES names a locale that is not generated)
if locale -a 2>/dev/null | string match -qi 'en_US.*'
    set -gx LC_MESSAGES en_US.UTF-8
end

# --- PATH ---
# Idempotent prepends: `contains` guard avoids duplicates in nested shells
# (fish_add_path would write universal variables and can duplicate entries
# already present in the inherited PATH, e.g. from ~/.profile or WSL interop).
function __fish_prepend_path
    for dir in $argv
        if test -d "$dir"; and not contains -- "$dir" $PATH
            set -p PATH "$dir"
        end
    end
end

__fish_prepend_path "$HOME/.local/bin"

# --- Rust ---
if test -f "$HOME/.cargo/env.fish"
    source "$HOME/.cargo/env.fish"
end

# --- bun ---
if test -x "$HOME/.bun/bin/bun"
    set -gx BUN_INSTALL "$HOME/.bun"
    __fish_prepend_path "$BUN_INSTALL/bin"
end

# --- OS-specific setup ---
switch (uname -s)
    case Darwin # macOS
        alias cursor="/Applications/Cursor.app/Contents/MacOS/Cursor"

        set -gx PNPM_HOME "$HOME/Library/pnpm"
        __fish_prepend_path "$PNPM_HOME" "/opt/local/bin" # MacPorts

    case Linux
        # Java: pin JDK 17 when available (Debian installs under /usr/lib/jvm;
        # glob covers amd64/arm64)
        for jvm in /usr/lib/jvm/java-17-openjdk-*
            set -gx JAVA_HOME $jvm
            break
        end

        # WSL detection for future use
        if string match -q -- "*[Mm]icrosoft*" (uname -r)
            # WSL specific settings
        end
end

# --- mise (polyglot version manager) ---
# Works in non-interactive shells too, so shims are always available.
if command -q mise
    mise activate fish | source
end

# --- Interactive session setup ---
if status is-interactive
    # GPG: pinentry needs the real terminal; only set when attached to one
    if isatty stdin
        set -gx GPG_TTY (tty)
    end
    if command -q gpg-connect-agent
        gpg-connect-agent reloadagent /bye >/dev/null 2>&1
    end

    # Prompt, history, directory jumping
    if command -q starship
        starship init fish | source
    end
    if command -q atuin
        atuin init fish --disable-up-arrow | source
    end
    if command -q zoxide
        zoxide init fish | source
    end

    # Shared Python virtualenv
    if test -f "$HOME/.venv/bin/activate.fish"
        source "$HOME/.venv/bin/activate.fish"
    end

    # --- Aliases ---
    alias emacs "emacs -nw"

    # Debian ships these tools under different names
    if command -q batcat; and not command -q bat
        alias bat batcat
    end
    if command -q fdfind; and not command -q fd
        alias fd fdfind
    end
end

# --- Disable greeting ---
function fish_greeting
end

# Helper no longer needed after startup; keep the namespace clean
functions -e __fish_prepend_path
