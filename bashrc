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
	export PAGER=less
else
	echo ".bashrc: less not installed using more"
	export PAGER=more
fi

# Setup less variables if necessary
if [ "$PAGER" == "less" ]; then
	# Options
	export LESS="-F -J -S -M -K -i -R -x4"

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
PROMPT_COMMAND="history -a"

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
#    Green     == more than 30% free disk space
#    Yellow    == less than 30% free disk space
#    Orange    == less than 10% free disk space
#    ALERT     == less than 5% free disk space
#    Red       == current user does not have write privileges
#    Cyan      == current filesystem is size zero (like /proc)
#
# $:
#    White     == no background or suspended jobs in this shell
#    Cyan      == at least one background job in this shell
#    Orange    == at least one suspended job in this shell

# Connected with ssh, unsecure remote, or local
if [ -n "${SSH_CONNECTION}" ]; then
	CNX_COLOR=${Green}
elif [[ "${DISPLAY%%:0*}" != "" ]]; then
	CNX_COLOR=${ALERT}
else
	CNX_COLOR=${BCyan}
fi

# User is root, not login user, or normal
if [[ ${USER} == "root" ]]; then
	USR_COLOR=${Red}
elif [[ ${USER} != $LOGNAME ]]; then
	USR_COLOR=${BRed}
else
	USR_COLOR=${BCyan}
fi

# Detemine load thresholds
NCPU=$(grep -cs 'processor' /proc/cpuinfo || sysctl -n hw.ncpu)
SLOAD=$((100*${NCPU})) # Small load
MLOAD=$((200*${NCPU})) # Medium load
XLOAD=$((400*${NCPU})) # Xlarge load

# Returns a color indicating system load.
load_color()
{
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
		USED=$(command df -P "$PWD" | awk 'END {print $5} {sub(/%/,"")}')

		if [ ${USED} -gt 95 ]; then
			echo -en ${ALERT}
		elif [ ${USED} -gt 90 ]; then
			echo -en ${BRed}
		elif [ ${USED} -gt 70 ]; then
			echo -en ${Yellow}
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

# Return git repository status
git_dirty_parse()
{
	local status=$(git status 2>&1 | tee)
	local dirty=$(echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?")
	local untracked=$(echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?")
	local ahead=$(echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?")
	local newfile=$(echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?")
	local renamed=$(echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?")
	local deleted=$(echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?")
	local bits=''

	if [ "${renamed}" == "0" ]; then
		bits=">${bits}"
	fi

	if [ "${ahead}" == "0" ]; then
		bits="*${bits}"
	fi

	if [ "${newfile}" == "0" ]; then
		bits="+${bits}"
	fi

	if [ "${untracked}" == "0" ]; then
		bits="?${bits}"
	fi

	if [ "${deleted}" == "0" ]; then
		bits="x${bits}"
	fi

	if [ "${dirty}" == "0" ]; then
		bits="!${bits}"
	fi

	if [ "${bits}" != "" ]; then
		echo " ${bits}"
	else
		echo ""
	fi
}

# Returns a color according to git repository status
git_branch()
{
	local BRANCH=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')

	if [ "${BRANCH}" != "" ]; then
		local STAT=$(git_dirty_parse)
		echo " (${BRANCH}${STAT})"
	else
		echo ""
	fi
}

# Returns a color according to return status of last command
return_color()
{
	if [ "$?" != "0" ]; then
		echo -en ${BRed}
	else
		echo -en ${NC}
	fi
}

create_ps1()
{
	RET_COLOR=$(return_color)

	# Time of day (with load info):
	PS1="[\[\$(load_color)\]\@\[${NC}\] "

	# User@Host (with connection type info):
	PS1+="\[${USR_COLOR}\]\u\[${NC}\]@\[${CNX_COLOR}\]\h\[${NC}\]:"

	# PWD (with 'disk space' info):
	PS1+="\[\$(disk_color)\]\W\[${NC}\]"

	# Job status and Git info:
	PS1+="\[\$(job_color)\]\$(git_branch)\[${NC}\]"

	# Prompt
	PS1+="]\[${RET_COLOR}\]\$\[${NC}\] "

	# Set title of current xterm:
	PS1+="\[\e]0;[\u@\h] \w\a\]"
}

# Now we construct the prompt.
case ${TERM} in
	*term* | rxvt | linux)
		PROMPT_COMMAND="create_ps1; ${PROMPT_COMMAND}";;
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
