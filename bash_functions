#!/usr/bin/env bash
#-------------------------------------------------------------------------------
# .bash_functions
#-------------------------------------------------------------------------------
# Handy Swap Program (possibly dangerous)
swap()
{
	local TMPFILE=tmp.$$

	[ $# -ne 2 ] && echo "swap: 2 arguments needed" && return 1
	[ ! -e $1 ] && echo "swap: $1 does not exist" && return 1
	[ ! -e $2 ] && echo "swap: $2 does not exit" && return 1

	mv "$1" "$TMPFILE"
	mv "$2" "$1"
	mv "$TMPFILE" "$2"
}


# Handy Extract Program
alias extract='ex'
extract()
{
	if [ -f $1 ] ; then
		case $1 in
			*.tar.bz2|*.tbz2) tar xvjf $1;;
			*.tar.gz|*.tgz) tar xvzf $1;;
			*.tar) tar xvf $1;;
			*.bz2) bunzip2 $1;;
			*.zip) unzip $1;;
			*.rar) unrar x $1;;
			*.gz) gunzip $1;;
			*.Z) uncompress $1;;
			*.7z) 7z x $1;;
			*) echo "'$1' cannot be extracted via extract()";;
		esac
	else
		echo "'$1' is not a valid file!"
	fi
}


# Wrapper to pv, like cp but with progess bar (possibly dangerous)
cpv()
{
	# create src and dst arrays trimmed
	local SRC=( "${@: 1: $#-1}" ); SRC=( "${SRC[@]%/}" )
	local DST=( "${@: -1}" ); DST=( "${DST[@]%/}" )

	# for some extra fun
	local FACES=("(o_o)" "(o_-)" "(-_o)" "(-_-)" "¯\_(O_o)_/¯")

	# ensure pv is installed and correct arguments
	[ "$(command -v pv)" ] || { echo "install pv first"; return 1; }
	[ $# -lt 2 ] && { echo "too few args"; return 1; }
	[ "$SRC" == "$DST" ] && { echo "src and dst must be different"; return 1; }

	# copy single file or dir to single file or dir
	if [ $# -eq 2 ]; then
		# exit if src doesnt exist
		[ -e "$SRC" ] || return 1;

		# copy single dir to single dir
		if [ -d "$SRC" ]; then
			[ -d "$DST" ] || mkdir -p "$DST"
			cpv "$SRC/"* "$DST"
		# copy single file to file or dir
		else
			[ -d "$DST" ] && DST="$DST/${SRC##*/}"

			# overwrite prompt
			if [ -f "$DST" ]; then
				read -p "$DST exists. overwrite (y/n): " -n 5
				[[ $REPLY =~ [Yy]$ ]] || return 0;
			fi

			# actual copy
			local face="${FACES[$RANDOM%${#FACES[@]}]}"
			echo "$face $SRC -> $DST"
			pv "$SRC" >| "$DST"
		fi

	# recursive copy
	else
		for src in "${SRC[@]}"; do
			# skip if src doesnt exist
			[ -e "$src" ] || continue
			local dst="$DST/${src##*/}"

			# recurse if src is a directory
			if [ -d "$src" ]; then
				[ -d "$dst" ] || mkdir -p "$dst";
				cpv "$src/"* "$dst"
			# copy if src is file
			else
				cpv "$src" "$dst"
			fi
		done
	fi

	return 0;
}


# Display most used commands
ctop()
{
	sed 's/|/\n/g' $HISTFILE | awk '{CMD[$1]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl |  head -n10
}


# Make directory then cd into it
mcd()
{
	mkdir -p $1
	cd $1
}


# Generate mandelbrot fractal with fixed point manipulation
mandelbrot()
{
	p=\>\>14 e=echo\ -ne\  S=(S H E L L) I=-16384 t=/tmp/m$$; for x in {1..13}; do \
	R=-32768; for y in {1..80}; do B=0 r=0 s=0 j=0 i=0; while [ $((B++)) -lt 32 -a \
	$(($s*$j)) -le 1073741824 ];do s=$(($r*$r$p)) j=$(($i*$i$p)) t=$(($s-$j+$R));
	i=$(((($r*$i)$p-1)+$I)) r=$t;done;if [ $B -ge 32 ];then $e\ ;else
	$e"\E[01;$(((B+3)%8+30))m${S[$((C++%5))]}"; fi;R=$((R+512));done;
	$e "\E[m\E(\r\n";I=$((I+1311)); done|tee $t;head -n 12 $t| tac
}


# Kill process by name
killps()
{
	local pid pname sig="-TERM"   # default signal
	if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
		echo "Usage: killps [-SIGNAL] pattern"
		return;
	fi
	if [ $# = 2 ]; then sig=$1 ; fi
	for pid in $(my_ps| awk '!/awk/ && $0~pat { print $1 }' pat=${!#} )
	do
		pname=$(my_ps | awk '$1~var { print $5 }' var=$pid )
		if ask "Kill process $pid <$pname> with signal $sig?"
			then kill $sig $pid
		fi
	done
}


# Repeat with n second delay between command
delay()
{
	[ -z "$1" ] && return

	local d=$1; shift;
	while [ 1 ]; do
		eval "$@"
		sleep $d
	done
}


# Repeat n times command.
repeat()
{
	local i max
	max=$1; shift;
	for ((i=0; i < max; i++)); do  # --> C-like syntax
		eval "$@";
	done
}


# Get name of app that created a corefile.
corename()
{
	for file in "$@"; do
		echo -n $file : ; gdb --core=$file --batch | head -1
	done
}


# Diff files side by side
alias sdiff='splitdiff'
splitdiff()
{
	diff -y -t --width="$COLUMNS" "$@"
}


# Diff binary files
alias bdiff='bindiff'
bindiff()
{
	left="$1"
	right="$2"
	shift 2
	splitdiff <(xxd "$left") <(xxd "$right") "$@"
}
