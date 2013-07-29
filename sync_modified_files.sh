#!/bin/bash

if [ "$#" -ne 0 ]; then
	while [ ! -z "$1" ]
	do
		case "$1" in
			-o) remote_path="$2";;
			-p) password="$2" ;;
			-u) username="$2" ;;
			-s) server="$2" ;;
			-h) echo "Help not available";exit ;;
			*) echo "Invalid option $1";exit ;;
		esac
		shift
		shift
	done
fi

##################### sync modified files from remote ###########################################################
echo "Checking whether files were modified..."
command="cd ${remote_path}; ls -l | cut --complement -f 3,4 -d \" \" | tail -n+2"
data=`sshpass -p $password ssh $username@$server ${command}`
# data=`ls dummy_remote -l | cut --complement -f 3,4 -d " " | tail -n+2`  
echo "$data" > remote_files.out
# echo "$data"
mtime=`sshpass -p $password ssh $username@$server 'stat -c"%Y" donotopen/* '`
# mtime=`stat -c%Y dummy_remote/*`
echo "$mtime" > remote_time.out
paste remote_files.out remote_time.out > remote_files_time.out
# ls dummy_data/ -l | cut --complement -f 3,4 -d " " | tail -n+2 > current_files.out
ls data/ -l | cut --complement -f 3,4 -d " " | tail -n+2 > current_files.out
stat -c%Y data/* > current_time.out
# stat -c%Y dummy_data/* > current_time.out
paste current_files.out current_time.out > current_files_time.out
paste remote_files_time.out current_files_time.out  | awk -F " " '{if($8>$16){print $7}}' > difference.out
# diff current_files.out remote_files.out -y > difference.out
# cat difference.out
if [ -z "`cat difference.out`" ]; then
	echo "No files to sync"
else
	if [ -z "`cat difference.out | tail -n+2 `" ]; then
		echo "Modified file are being copied"
		echo "File copied :"
		for file in `cat difference.out`;do printf "$file \n"; sshpass -p $password scp -p  $username@$server:$remote_path/$file "data/"; done
	else
		echo "Modified files are being copied"
		echo "Files copied :"
		for file in `cat difference.out`;do printf "$file \n"; files="$files$file,"; done
		files=`echo ${files%?}`
		sshpass -p $password scp -p  $username@$server:$remote_path/{$files} "data/"
	fi
	# diff --changed-group-format='%>' --unchanged-group-format='' current_files.out remote_files.out | awk '{print $7}' > difference.out
	# for file in `cat difference.out`; do cp -pv "./dummy_remote/$file" ./dummy_data/; done
	echo "files up to date"
fi

printf "\n"
