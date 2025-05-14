if status is-interactive
    # Commands to run in interactive sessions can go here
    source "$HOME/.cargo/env.fish"
    source (starship init fish --print-full-init | psub)
    if test -f ~/.venv/bin/activate.fish
        source $HOME/.venv/bin/activate.fish
    end
end
