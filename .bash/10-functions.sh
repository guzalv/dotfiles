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

function mkcd
{
    local new_dir="${1}"
    mkdir -p "${new_dir}"
    cd "${new_dir}"
}

function sshn
{
    ssh \
    -o UserKnownHostsFile=/dev/null \
    -o StrictHostKeyChecking=no \
    "$@"
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
