# If not running interactively, don't do anything
#[ -z "$PS1" ] && return

bashrc_location=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Source configuration files
for f in "${bashrc_location}/.bash/"*; do
	source "$f"
done

. "$HOME/.local/bin/env"

# opencode
export PATH=/Users/gualvare/.opencode/bin:$PATH

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/gualvare/.lmstudio/bin"
# End of LM Studio CLI section

