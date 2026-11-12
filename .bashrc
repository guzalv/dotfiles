# If not running interactively, don't do anything
#[ -z "$PS1" ] && return

bashrc_location=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Source configuration files
for f in "${bashrc_location}/.bash/"*; do
	[ -f "$f" ] && source "$f"
done

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# Platform-specific config
os_file="${bashrc_location}/.bash/os/$(uname -s).sh"
[ -f "$os_file" ] && source "$os_file"

