#/usr/bin/env bash
file_list="profile bashrc bash_aliases bash_functions inputrc nanorc gitconfig"

for file in $file_list; do
	if ! diff -N -q "$file" "${HOME}/.$file"; then
		cp -i "$file" "${HOME}/.$file"
	fi
done
