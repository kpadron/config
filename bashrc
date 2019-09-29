#!/usr/bin/env bash
#-------------------------------------------------------------------------------
# .bashrc
#-------------------------------------------------------------------------------
# If not running interactively, don't do anything
[ -z "$PS1" ] && return

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
if [ -n "$(type -t nano)" ]; then
	export EDITOR=nano
elif [ -n "$(type -t vim)" ]; then
	echo ".bashrc: nano not installed using vim"
	export EDITOR=vim
else
	echo ".bashrc: vim not installed using vi"
	export EDITOR=vi
fi
export VISUAL="$EDITOR"

# Default pager, prefer less
if [ -n "$(type -t less)" ]; then
	export PAGER=less
else
	echo ".bashrc: less not installed using more"
	export PAGER=more
fi

# Setup less variables if necessary
if [ "$PAGER" == "less" ]; then
	# Options
	export LESS="-F -X -S -M -i -R -x4"

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
shopt -s cmdhist histappend histreedit histverify
HISTFILE="${HOME}/.bash_history"
HISTSIZE=5000
HISTFILESIZE=10000
HISTCONTROL=ignoreboth

# Time format to use whenever keyword time is used
TIMEFORMAT=$'\nreal %3R\tuser %3U\tsys %3S\tpcpu %P\n'


#-------------------------------------------------------------------------------
# COLOR SETTINGS
#-------------------------------------------------------------------------------
# Enable color support
if [ -x "$(type -p dircolors)" ]; then
	[ -r "${HOME}/.dircolors" ] && eval $(dircolors -b "${HOME}/.dircolors") || eval $(dircolors -b)
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
# []:
#    White     == no jobs in this shell
#    Cyan      == background jobs in this shell
#    Orange    == suspended jobs in this shell
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
#    White     == last command return status was success (zero)
#    Red       == last command return status was failure (non-zero)

# Connected with ssh, unsecure remote, or local
if [ -n "$SSH_CONNECTION" ]; then
	CNX_COLOR=${Green}
elif [ -n "${DISPLAY%%:0*}" ]; then
	CNX_COLOR=${ALERT}
else
	CNX_COLOR=${BCyan}
fi

# User is root, not login user, or normal
if [ "$USER" == "root" ]; then
	USR_COLOR=${Red}
elif [ "$USER" != "$LOGNAME" ]; then
	USR_COLOR=${BRed}
else
	USR_COLOR=${BCyan}
fi

# Detemine load thresholds
NCPU=$(nproc --all || sysctl -n hw.ncpu || getconf _NPROCESSORS_ONLN)
let "SLOAD = 100 * NCPU" # Small load
let "MLOAD = 200 * NCPU" # Medium load
let "XLOAD = 400 * NCPU" # Extreme load

# Return git repository status
git_status()
{
	git status --porcelain --branch 2>/dev/null | (
		unset branch dirty deleted untracked newfile copied renamed bits status
		local branch dirty deleted untracked newfile copied renamed bits status
		while read line ; do
			case "${line//[:space:]]/}" in
				'##'*) branch="$(echo "${line:3}" | awk -F '[.][.][.]' '{print $1}')" ; ;;
				@('M'|'UU')*) dirty='!' ; ;;
				'D'*) deleted='x' ; ;;
				'??'*) untracked='?' ; ;;
				'A'*) newfile='+' ; ;;
				'C'*) copied='|' ; ;;
				'R'*) renamed='>' ; ;;
			esac
		done

		bits="${dirty}${deleted}${untracked}${newfile}${copied}${renamed}"
		[ -n "$bits" ] && status="${branch} ${bits}" || status="${branch}"
		[ -n "$status" ] && echo " ($status)" || echo
	)
}

create_ps1()
{
	# Determine if the last command was successful
	if [ "$?" != "0" ]; then
		local RETURN_STATUS_COLOR=${BRed}
	else
		local RETURN_STATUS_COLOR=${NC}
	fi

	# Determine the current system load
	local SYSLOAD=$(uptime)
	SYSLOAD=${SYSLOAD##*: }
	SYSLOAD=${SYSLOAD%%,*}
	SYSLOAD=${SYSLOAD//.}
	SYSLOAD=$((10#$SYSLOAD))

	# Small, medium or extreme system load
	local SYSTEM_LOAD_COLOR
	if (("$SYSLOAD" > "$XLOAD")); then
		SYSTEM_LOAD_COLOR=${ALERT}
	elif (("$SYSLOAD" > "$MLOAD")); then
		SYSTEM_LOAD_COLOR=${Red}
	elif (("$SYSLOAD" >  "$SLOAD")); then
		SYSTEM_LOAD_COLOR=${BRed}
	else
		SYSTEM_LOAD_COLOR=${Green}
	fi

	# Determine read-only, disk space, or special directory
	local DISK_USAGE_COLOR
	if [ ! -w "$PWD" ]; then
		DISK_USAGE_COLOR=${Red}
	elif [ -s "$PWD" ]; then
		local DISK_USAGE=$(df --output=pcent "$PWD")
		DISK_USAGE=${DISK_USAGE//[!0-9]/}

		if (("$DISK_USAGE" > 95)); then
			DISK_USAGE_COLOR=${ALERT}
		elif (("$DISK_USAGE" > 90)); then
			DISK_USAGE_COLOR=${BRed}
		elif (("$DISK_USAGE" > 70)); then
			DISK_USAGE_COLOR=${Yellow}
		else
			DISK_USAGE_COLOR=${Green}
		fi
	else
		DISK_USAGE_COLOR=${Cyan}
	fi

	# Determine job status
	local JOB_STATUS_COLOR
	if [ -n "$(jobs -s)" ]; then
		JOB_STATUS_COLOR=${BRed}
	elif [ -n "$(jobs -r)" ]; then
		JOB_STATUS_COLOR=${BCyan}
	else
		JOB_STATUS_COLOR=${NC}
	fi

	# Determine git status
	local GIT_STATUS_STR=$(git_status)

	# Time of day (with load info):
	PS1="\[${JOB_STATUS_COLOR}\][\[${SYSTEM_LOAD_COLOR}\]\@\[${NC}\] "

	# User@Host (with connection info):
	PS1+="\[${USR_COLOR}\]\u\[${NC}\]@\[${CNX_COLOR}\]\h\[${NC}\]:"

	# PWD (with disk space info):
	PS1+="\[${DISK_USAGE_COLOR}\]\W\[${NC}\]"

	# Git info:
	PS1+="${GIT_STATUS_STR}\[${NC}\]"

	# Prompt
	PS1+="\[${JOB_STATUS_COLOR}\]]\[${RETURN_STATUS_COLOR}\]\\$\[${NC}\] "
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
