# shellcheck disable=SC2148
# /etc/skel/.bashrc
# This bashrc file is created by Chawye Hsu, licensed under the MIT license.
#------------------------------------------------------------------------------#
# Support Platforms:
#      macOS: Bash
#      Linux: Bash
#------------------------------------------------------------------------------#

# https://github.com/mathiasbynens/dotfiles/blob/main/.bash_profile
# Test for an interactive shell.
[[ $- != *i* ]] && return
# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob
# Append to the Bash history file, rather than overwriting it
shopt -s histappend
# Autocorrect typos in path names when using `cd`
shopt -s cdspell
# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
    shopt -s "$option" 2>/dev/null
done

# Xterm colors
[ "$TERM" == "xterm" ] && export TERM=xterm-256color
# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh
# Add tab completion for `defaults read|write NSGlobalDomain`
# You could just use `-g` instead, but I like being explicit
complete -W "NSGlobalDomain" defaults

#-------------------------------------#
# Program-languages specific settings #
#-------------------------------------#

# Use bash-completion, if available
# shellcheck source=/dev/null
[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] &&
    . /usr/share/bash-completion/bash_completion

# shellcheck source=/dev/null
source "$HOME/.export"

if [ -d ~/.bash_completion.d ]; then
    for file in ~/.bash_completion.d/*; do
        # shellcheck disable=SC1090
        # shellcheck disable=SC2086
        . $file
    done
fi

#----------------------------#
# The Chawye's styled prompt #
#----------------------------#

# Shell prompt based on the Solarized Dark theme.
# Screenshot: http://i.imgur.com/EkEtphC.png
# Heavily inspired by @necolas’s prompt: https://github.com/necolas/dotfiles
# iTerm → Profiles → Text → use 13pt Monaco with 1.1 vertical spacing.

function styled_prompt() {
    # Color table
    local RESET="\[\033[0m\]"
    # shellcheck disable=SC2034
    local BLACK="\[\033[0;30m\]"
    # shellcheck disable=SC2034
    local RED="\[\033[0;31m\]"
    local GREEN="\[\033[0;32m\]"
    local YELLOW="\[\033[0;33m\]"
    # shellcheck disable=SC2034
    local BLUE="\[\033[0;34m\]"
    # shellcheck disable=SC2034
    local MAGENTA="\[\033[0;35m\]"
    local CYAN="\[\033[0;36m\]"
    # shellcheck disable=SC2034
    local WHITE="\[\033[0;37m\]"
    # Terminal title
    local TERMTITLE="\[\e]0; \w\a\]"

    DIST=""
    # git-prompt
    [ "$(type -t __git_ps1)" = 'function' ] && GITPS1="\$(__git_ps1 ' (%s)')"

    # PS1 command substitution issue with newline:
    #  https://stackoverflow.com/questions/33220492/
    #  https://stackoverflow.com/questions/21517281/
    # __git_ps1 not update issue:
    #  https://askubuntu.com/questions/896445/#comment2153553_1163371
    PS1="$TERMTITLE$GREEN\h$DIST $YELLOW\W$CYAN$GITPS1$RESET"$'\n$ '
}
styled_prompt
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# shellcheck disable=SC1090
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
