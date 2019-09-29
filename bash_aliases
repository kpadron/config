#!/usr/bin env bash
#-------------------------------------------------------------------------------
# .bash_aliases
#-------------------------------------------------------------------------------
# Add ls aliases
alias ls='ls -CF --color=always'
alias la='ls -A'
alias ll='ls -hlF'
alias lr='ls -R'
alias lla='ls -lAF'
alias llr='ll -R'
alias l.='ls -d .*'

# Enable color
alias dir='dir --color=always'
alias vdir='vdir --color=always'
alias grep='grep --color=always'
alias fgrep='fgrep --color=always'
alias egrep='egrep --color=always'
alias diff='diff --color=always'

# Prefer colordiff if possible
if [ -n "$(type -t colordiff)" ]; then
	alias diff='colordiff'
fi

# Editor aliases
alias edit="$EDITOR"
alias e='edit'
alias sb='. ~/.bashrc'
alias eb='e ~/.bashrc'

# Git aliases
alias gits='git status'
alias gita='git add'

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

# Network aliases
alias socks='sudo netstat -tuap'

# Path aliases
alias path='echo -e ${PATH//:/\\n}'
alias libpath='echo -e ${LD_LIBRARY_PATH//:/\\n}'
