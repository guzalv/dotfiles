# If .bashrc.work_specific exists, source it
bashrc_location=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
if [ -r "${bashrc_location}"/.bashrc.work_specific ]; then
    source "${bashrc_location}"/.bashrc.work_specific
fi

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Aliases
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"' # Usage: sleep 10; alert
alias c="cat"
alias cd..="cd .."
alias cd-="cd -"
alias cp="cp -i"
alias cscope="cscope -d -f $CSCOPE_DB"
alias du="du -hs * 2> /dev/zero  | sort -h"
alias e="echo"
alias f="find . -name"
alias g="git"
alias ga="git add"
alias gb="git branch"
alias gc="git checkout"
alias gci="git commit"
alias gca="git commit --amend"
alias gd="git diff"
alias gdt="git diff-tree --no-commit-id --name-only -r"
alias gg="git grep -n"
alias gga="git branch -a | tr -d \* | sed '/->/d' | xargs git grep"
alias gl="git log"
alias gpr="git pull --rebase"
alias gprom="git pull --rebase origin master"
alias gr="git reset"
alias gs="git status"
alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"
alias rgrep="grep -R"
alias kb="setxkbmap"
alias ls="ls --color -F"
alias ll="ls -ahlF"
alias la="ls -A"
alias lltr="ls -ltr"
alias l="ls -CFl"
alias ks="ls"
alias matlabcli="matlab -nodisplay -nojvm"
alias mv="mv -i"
alias p8="ping 8.8.8.8"
alias rm="rm -I"
alias v="vim"
alias :q="exit"

# Functions
function parse_git_branch
{
    # Idea by J. Judin (https://github.com/Barro)
    git branch --no-color 2>/dev/null | grep \* | sed "s/\* \(.*\)/ \1:/"
}

function close
{
    # First, be nice
    for PID in `pgrep "${1%.*}"`; do kill -SIGINT ${PID} &> /dev/null & done

    sleep 2

    # Then, be aggressive
    for PID in `pgrep "${1%.*}"`; do kill -SIGKILL ${PID} &> /dev/null & done
}

function gitd
{
    # We are using a git hack (worktree="../../") in order to version control
    # the home directory but not have a .git directory there. This forces to
    # run git commands from ~/dotfiles, some of which don't work. This function
    # uses the fact that git reads the gitdir from a file called .git so that
    # we can run git commands from the home directory if needed.

    # This could be done more easily with an alias:
    # alias gitd="git --git-dir=/home/${USER}/dotfiles/.git"
    # But that would work from anywhere which can be confusing.
    local git_location_file=${HOME}/.git
    echo "gitdir: ${HOME}/dotfiles/.git" > "${git_location_file}"
    git "${@}"
    rm -f "${git_location_file}"
}

function git_add_modified
{
    git status | grep "modified:" | cut -d ":" -f 2 | xargs -n 1 git add
}

function git_rm_deleted
{
    git status | grep "deleted:" | cut -d ":" -f 2 | xargs -n 1 git rm
}

function human_hostname
{
    if type human_hostname_work &> /dev/zero; then
        hostname=$(human_hostname_work)
    else
        hostname=$(hostname)
    fi

    case "${hostname}" in
        mb.local)
            echo home
            ;;
        *)
            echo "${hostname}"
            ;;
    esac
}

function mkcd
{
    local new_dir="${1}"
    mkdir -p "${new_dir}"
    cd "${new_dir}"
}

function ssht
{
    test -n "$1" && ssh -t "$1" "bash -l"
}

function stress
{
    if [ "${1:-}" = "stop" ]; then
        killall yes
    else
        local num_processes=${1:-1}
        for i in $(seq 1 ${num_processes}); do yes>/dev/zero& done
    fi
}

function g
{
    grep $@
}

# Cosmetics
export PS1='\
\[\e[1m\]\u\[\e[0m\]\
@\
\[\e[1;32m\]'"$(human_hostname)"'\[\e[0m\] \
[\A]\
\[\e[1;95m\]$(parse_git_branch)\[\e[0m\] \
\[\e[1;34m\]${PWD#${PWD%/*/*}/}\[\e[0m\] \$ '

# Env variables
export CSCOPE_DB="${HOME}/Documents/cscope/cscope.out"

# Misc settings from Ubuntu default .bashrc
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000

shopt -s histappend
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# If .bashrc.os_specific.macos exists and we are on a Mac, source it
if [ -r "${bashrc_location}"/.bashrc.os_specific.macos ] && \
    [ "$(uname)" = "Darwin"  ]; then
    source "${bashrc_location}"/.bashrc.os_specific.macos
fi
