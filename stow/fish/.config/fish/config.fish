if status is-interactive
    # Commands to run in interactive sessions can go here
    fish_add_path "$HOME/.volta/bin"
    set -gx GPG_TTY (tty)
    set -Ux EDITOR vim
    set -gx VOLTA_HOME "$HOME/.volta"
    source "$HOME/.cargo/env.fish"
    source (starship init fish --print-full-init | psub)
    if test -f ~/.venv/bin/activate.fish
        source $HOME/.venv/bin/activate.fish
    end
end

alias cursor="/Applications/Cursor.app/Contents/MacOS/Cursor"

function fish_greeting
end


# pnpm
set -gx PNPM_HOME "/Users/friendsa/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# chsrc
set -gx CHSRC_HOME "$HOME/.local/bin/"
if not string match -q -- $CHSRC_HOME $PATH
  set -gx PATH "$CHSRC_HOME" $PATH
end
# chsrc end

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
