#!/usr/bin/env bash
dir="`pwd`"

# Make sure directory ends with "/"
if [[ $dir != */ ]]
then
	dir="$dir/*"
else
	dir="$dir*"
fi

# Loop all sub-directories
for f in $dir
do
	# Only interested in directories
	[ -d "${f}" ] || continue

        repo="$(echo ${f} |cut -d '/' -f5)"

	echo -n "[*] checking : "
	echo -en "\033[0;35m"
        echo "${f}"
	echo -en "\033[0m"

	# Check if directory is a git repository
	if [ -d "$f/.git" ]
	then
		mod=0
		cd $f

		# Check for modified files
		if [ $(git status | grep modified -c) -ne 0 ]
		then
			mod=1
			echo -en "\033[0;33m"
			echo -n "[+] modified local files"
			echo -en "\033[0m"
		fi

		# Check for untracked files
		if [ $(git status | grep Untracked -c) -ne 0 ]
		then
			mod=1
			echo -en "\033[0;33m"
			echo -n "[+] untracked local files"
			echo -en "\033[0m"
		fi
		
		# Check for unpushed changes
		if [ $(git status | grep 'Your branch is ahead' -c) -ne 0 ]
		then
			mod=1
			echo -en "\033[0;33m"
			echo -n "[+] unpushed commit"
			echo -en "\033[0m"
		fi

                # Check for remote updates
                if [ $(git status -uno | grep 'Your branch is behind' -c) -ne 0 ]
                then
                        mod=1
			echo -en "\033[0;33m"
			echo -n "[+] remote has updates"
			echo -en "\033[0m"
                fi

		if [ $mod -eq 0 ]
		then
			echo -en "\033[0;32m"
			echo -n "[+] all good"
			echo -en "\033[0m"
		fi

		cd ../
	else
	        echo -en "\033[0;31m"
		echo -n "[x] not a git repository"
		echo -en "\033[0m"
	fi
	echo
done
