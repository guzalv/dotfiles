# Dotfiles

Random dotfiles accumulated over time

## Installation

```bash
cd
git clone https://github.com/guzalv/dotfiles
cd dotfiles
sed -i '/\[core\]/a \\tworktree = ../..' .git/config
git reset --hard
cd
source .bashrc
