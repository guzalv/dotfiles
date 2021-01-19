# Sane default editor
EDITOR=vi

# History settings
HISTCONTROL=ignoredups
HISTSIZE=10000
HISTFILESIZE=20000

shopt -s histappend
shopt -s checkwinsize

# Less stuff (taken from https://github.com/nablaa/dotfiles/blob/master/.zsh/environment.zsh)
# R - Raw color codes in output (don't remove color codes)
# S - Don't wrap lines, just cut off too long text
# M - Long prompts ("Line X of Y")
# ~ - Don't show those weird ~ symbols on lines after EOF
# g - Highlight results when searching with slash key (/)
# I - Case insensitive search
# s - Squeeze empty lines to one
# w - Highlight first line after PgDn
export LESS="-RSM~gIsw"

# Less Colors for Man Pages
export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\E[0m'           # end mode
export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\E[01;31m'       # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'           # end underline
export LESS_TERMCAP_us=$'\E[01;32m' # begin underline

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# More colors for "ls" command
eval "$(dircolors -b)"

# Sync history between terminals
export PROMPT_COMMAND="${PROMPT_COMMAND:-:}; history -a; history -n"

# Use Bash completion
if [ -r /etc/bash_completion ]; then
    source /etc/bash_completion
elif [ -r /usr/share/bash-completion/bash_completion ]; then
    source /usr/share/bash-completion/bash_completion
fi

# set PATH so it includes user's private bin directories
for directory in $(find ~/bin -type d -not -path "*.git*"); do
    PATH="${directory}:${PATH}"
done
