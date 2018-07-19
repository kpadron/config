#!/usr/bin env bash
#-------------------------------------------------------------------------------
# .bash_aliases
#-------------------------------------------------------------------------------
# OS specific aliases
case $(uname -s) in
	Linux)
	alias ls='ls -hCF --color --group-directories-first'
	alias update='sudo apt-get update'
	alias upgrade='sudo apt-get upgrade -y';;

	FreeBSD)
	alias ls='ls -hCF --color'
	alias update='sudo pkg update'
	alias upgrade='sudo pkg upgrade -y';;
	*);;
esac

# Add ls aliases
alias la='ls -a'
alias ll='ls -la'
alias lr='ls -R'
alias llr="ll -R"
alias l.='ls -d .*'

# Enable color
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Editor aliases
alias edit="$EDITOR"
alias e='edit'
alias sb='. ~/.bashrc'
alias eb='e ~/.bashrc'

# File operation aliases
alias mkdir='mkdir -p'
alias md='mkdir'
alias mv='mv -i'
alias cp='cp -i'
alias rm='rm -I'
alias cd..='cd ..'
alias ..='cd ..'

# Shell environment aliases
alias root='sudo -i'
alias which='type -a'
alias h='history'
alias j='jobs -l'
alias cl='clear'
alias quit='exit'

# Path aliases
alias path='echo -e ${PATH//:/\\n}'
alias libpath='echo -e ${LD_LIBRARY_PATH//:/\\n}'
