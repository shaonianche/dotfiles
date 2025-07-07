# --- Common interactive setup ---
if status is-interactive
    set -gx GPG_TTY (tty)
    set -Ux EDITOR vim
    set -gx VOLTA_HOME "$HOME/.volta"
    source "$HOME/.cargo/env.fish"
    starship init fish | source
    if test -f ~/.venv/bin/activate.fish
        source ~/.venv/bin/activate.fish
    end
end

function fish_greeting
end

# --- Common PATH and environment setup ---
# Use fish_add_path to avoid duplicate entries and keep the config clean.

# chsrc
fish_add_path "$HOME/.local/bin"

# bun
set --export BUN_INSTALL "$HOME/.bun"
fish_add_path "$BUN_INSTALL/bin"

# opencode
fish_add_path "$HOME/.opencode/bin"
fish_add_path "$HOME/.volta/bin"

# --- OS-specific setup ---
# Detect OS for specific configurations
switch (uname -s)
    case Darwin # This is macOS
        # macOS specific aliases
        alias cursor="/Applications/Cursor.app/Contents/MacOS/Cursor"

        # macOS specific PATHs
        set -gx PNPM_HOME "/Users/friendsa/Library/pnpm"
        fish_add_path "$PNPM_HOME"
        fish_add_path "/opt/local/bin" # macports

    case Linux
        # Check if it's WSL by inspecting the kernel release info
        if string match -q -- "*[Mm]icrosoft*" (uname -r)
            # WSL specific aliases
        end
        # You can add other generic Linux settings here if needed
end