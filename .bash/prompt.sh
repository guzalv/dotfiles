export PS1='\
\[\e[1m\]\u\[\e[0m\]\
@\
\[\e[1;32m\]'"$(human_hostname)"'\[\e[0m\] \
[\A]\
\[\e[1;95m\]$(parse_git_branch)\[\e[0m\] \
\[\e[1;34m\]${PWD#${PWD%/*/*}/}\[\e[0m\] \$ '
