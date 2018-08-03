#!usr/bin/env bash
#-------------------------------------------------------------------------------
# .bashrc
#-------------------------------------------------------------------------------
# If not running interactively, don't do anything
case $- in
	*i*) ;;
	  *) return;;
esac

# Source global definitions
[ -r /etc/bashrc ] && . /etc/bashrc


#-------------------------------------------------------------------------------
# SHELL SETTINGS
#-------------------------------------------------------------------------------
# disable core dumps
ulimit -c 0 > /dev/null 2>&1

# case insenstive completion
bind "set completion-ignore-case on"
bind "set show-all-if-ambiguous on"

# enable options
set -o notify
set -o noclobber
set -o ignoreeof

shopt -s autocd
shopt -s cdable_vars
shopt -s cdspell

shopt -s checkhash
shopt -s checkwinsize

shopt -s sourcepath
shopt -s no_empty_cmd_completion
shopt -s extglob
shopt -s hostcomplete


#-------------------------------------------------------------------------------
# DEFAULT APPS
#-------------------------------------------------------------------------------
# Default editor, prefer nano
if [ "$(command -v nano)" ]; then
	export EDITOR=nano
else
	echo ".bashrc: nano not installed using vim"
	export EDITOR=vim
fi
export VISUAL="$EDITOR"

# Default pager, prefer less
if [ "$(command -v less)" ]; then
	echo ".bashrc: most not installed using less"
	export PAGER=less
else
	echo ".bashrc: less not installed using more"
	export PAGER=more
fi

# Setup less variables if necessary
if [ "$PAGER" == "less" ]; then
	# Options
	export LESS="-F -i -R -x4"

	# Colors
	export LESS_TERMCAP_mb=$'\E[01;31m'
	export LESS_TERMCAP_md=$'\E[01;36m'
	export LESS_TERMCAP_me=$'\E[0m'
	export LESS_TERMCAP_so=$'\E[01;44;33m'
	export LESS_TERMCAP_se=$'\E[0m'
	export LESS_TERMCAP_us=$'\E[01;32m'
	export LESS_TERMCAP_ue=$'\E[0m'
fi

# Pager aliases
alias more="$PAGER"
alias less="$PAGER"
alias most="$PAGER"


#-------------------------------------------------------------------------------
# HISTORY & OTHER SETTINGS
#-------------------------------------------------------------------------------
# Append to history and erase duplicate commands
shopt -s histappend histreedit histverify cmdhist
HISTFILE="${HOME}/.bash_history"
HISTSIZE=5000
HISTFILESIZE=10000
HISTCONTROL=ignorespace:erasedups

# Time format to use whenever keyword time is used
TIMEFORMAT=$'\nreal %3R\tuser %3U\tsys %3S\tpcpu %P\n'

# File to read for hostname completion
HOSTFILE="~/.hosts"


#-------------------------------------------------------------------------------
# COLOR SETTINGS
#-------------------------------------------------------------------------------
# Enable color support
if [ "$(command -v dircolors)" ]; then
	[ -r "${HOME}/.dircolors" ] && eval "$(dircolors -b ${HOME}/.dircolors)" || eval "$(dircolors -b)"
fi

# Normal Colors
Black='\e[0;30m'
Red='\e[0;31m'
Green='\e[0;32m'
Yellow='\e[0;33m'
Blue='\e[0;34m'
Purple='\e[0;35m'
Cyan='\e[0;36m'
White='\e[0;37m'

# Bold
BBlack='\e[1;30m'
BRed='\e[1;31m'
BGreen='\e[1;32m'
BYellow='\e[1;33m'
BBlue='\e[1;34m'
BPurple='\e[1;35m'
BCyan='\e[1;36m'
BWhite='\e[1;37m'

# Background
On_Black='\e[40m'
On_Red='\e[41m'
On_Green='\e[42m'
On_Yellow='\e[43m'
On_Blue='\e[44m'
On_Purple='\e[45m'
On_Cyan='\e[46m'
On_White='\e[47m'

# Color Reset
NC="\e[m"

# Bold White on red background
ALERT=${BWhite}${On_Red}

_exit()
{
	echo -e "${BRed}Hasta la vista, baby${NC}"
	sleep 0.5
}
trap _exit EXIT


#-------------------------------------------------------------------------------
# SHELL PROMPT
#-------------------------------------------------------------------------------
# Current Format: [TIME USER@HOST PWD (GIT)]$
#
# TIME:
#    Green     == machine load is low
#    Orange    == machine load is medium
#    Red       == machine load is high
#    ALERT     == machine load is very high
#
# USER:
#    Cyan      == normal user
#    Orange    == SU to user
#    Red       == root
#
# HOST:
#    Cyan      == local session
#    Green     == secured remote connection (via ssh)
#    Red       == unsecured remote connection
#
# PWD:
#    Green     == more than 10% free disk space
#    Orange    == less than 10% free disk space
#    ALERT     == less than 5% free disk space
#    Red       == current user does not have write privileges
#    Cyan      == current filesystem is size zero (like /proc)
#
# $:
#    White     == no background or suspended jobs in this shell
#    Cyan      == at least one background job in this shell
#    Orange    == at least one suspended job in this shell

# Returns a color indication remote connection type.
connection_color()
{
	# Connected with ssh, unsecure remote, or local
	if [ -n "${SSH_CONNECTION}" ]; then
		echo -en ${Green}
	elif [[ "${DISPLAY%%:0*}" != "" ]]; then
		echo -en ${ALERT}
	else
		echo -en ${BCyan}
	fi
}

# Returns a color indicating user type.
user_color()
{
	# User is root, not login user, or normal
	if [[ ${USER} == "root" ]]; then
		echo -en ${Red}
	elif [[ ${USER} != $LOGNAME ]]; then
		echo -en ${BRed}
	else
		echo -en ${BCyan}
	fi
}

# Returns a color indicating system load.
load_color()
{
	# Detemine load thresholds
	local NCPU=$(grep -cs 'processor' /proc/cpuinfo || sysctl -n hw.ncpu)
	local SLOAD=$(( 100*${NCPU} )) # Small load
	local MLOAD=$(( 200*${NCPU} )) # Medium load
	local XLOAD=$(( 400*${NCPU} )) # Xlarge load

	# System load of the current host.
	local SYSLOAD=$(uptime)
	SYSLOAD=${SYSLOAD##*: }
	SYSLOAD=${SYSLOAD%%,*}
	SYSLOAD=${SYSLOAD//.}
	SYSLOAD=$((10#$SYSLOAD))

	# Small, medium or large system load
	if [ ${SYSLOAD} -gt ${XLOAD} ]; then
		echo -en ${ALERT}
	elif [ ${SYSLOAD} -gt ${MLOAD} ]; then
		echo -en ${Red}
	elif [ ${SYSLOAD} -gt ${SLOAD} ]; then
		echo -en ${BRed}
	else
		echo -en ${Green}
	fi
}

# Returns a color according to free disk space in $PWD.
disk_color()
{
	# Readonly, disk space, or special directory
	if [ ! -w "${PWD}" ]; then
		echo -en ${Red}
	elif [ -s "${PWD}" ]; then
		local used=$(command df -P "$PWD" | awk 'END {print $5} {sub(/%/,"")}')

		if [ ${used} -gt 95 ]; then
			echo -en ${ALERT}
		elif [ ${used} -gt 90 ]; then
			echo -en ${BRed}
		else
			echo -en ${Green}
		fi
	else
		echo -en ${Cyan}
	fi
}

# Returns a color according to running/suspended jobs.
job_color()
{
	if [ $(jobs -s | wc -l) -gt "0" ]; then
		echo -en ${BRed}
	elif [ $(jobs -r | wc -l) -gt "0" ]; then
		echo -en ${BCyan}
	fi
}

# Returns a color according to git repository status
git_branch()
{
	local BRANCH=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')

	if [ ! "${BRANCH}" == "" ]; then
		echo " (${BRANCH})"
	else
		echo ""
	fi
}


# Now we construct the prompt.
case ${TERM} in
	*term* | rxvt | linux)
		# Time of day (with load info):
		PS1="[\[\$(load_color)\]\@\[${NC}\] "
		# User@Host (with connection type info):
		PS1=${PS1}"\[\$(user_color)\]\u\[${NC}\]@\[\$(connection_color)\]\h\[${NC}\]:"
		# PWD (with 'disk space' info):
		PS1=${PS1}"\[\$(disk_color)\]\W\[${NC}\]"
		# Job status and Git info:
		PS1=${PS1}"\[\$(job_color)\]\$(git_branch)\[${NC}\]"
		# Prompt
		PS1=${PS1}"]\$\[${NC}\] "
		# Set title of current xterm:
		PS1=${PS1}"\[\e]0;[\u@\h] \w\a\]";;
	*)
		# PS1="(\A \u@\h \w) $ "
		PS1="\A \u@\h:\W\$ ";;
esac


#-------------------------------------------------------------------------------
# ALIASES AND FUNCTIONS
#-------------------------------------------------------------------------------
# Source bash alias file
[ -r "${HOME}/.bash_aliases" ] && . "${HOME}/.bash_aliases"

# Source bash function file
[ -r "${HOME}/.bash_functions" ] && . "${HOME}/.bash_functions"
