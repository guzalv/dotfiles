# If .bashrc.work_specific exists, source it
bashrc_location=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
if [ -r "${bashrc_location}"/.bashrc.work_specific ]; then
    source "${bashrc_location}"/.bashrc.work_specific
fi

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Source configuration files
for f in "${bashrc_location}/.bash/"*; do
    source "$f"
done

# If .bashrc.os_specific.macos exists and we are on a Mac, source it
if [ -r "${bashrc_location}"/.bashrc.os_specific.macos ] && \
    [ "$(uname)" = "Darwin"  ]; then
    source "${bashrc_location}"/.bashrc.os_specific.macos
fi
