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

#####################copy all newly created files into local########################################
echo "Checking if new files were created "
command="cd ${remote_path}; ls -l | cut --complement -f 3,4 -d \" \" | tail -n+2"
data=`sshpass -p $password ssh $username@$server $command`
# data=`ls dummy_remote -ltr | cut --complement -f 3,4 -d " " | tail -n+2 | awk -F " " '{ print $7 }' | sort`
# echo $data | head
echo "$data" > temp.out
cat temp.out | awk -F " " '{ print $7 }' | sort > remote_files.out
# ls dummy_data -ltr | cut --complement -f 3,4 -d " " | tail -n+2 | awk -F " " '{ print $7 }' | sort > current_files.out
ls data -ltr | cut --complement -f 3,4 -d " " | tail -n+2 | awk -F " " '{ print $7 }' | sort > current_files.out
diff remote_files.out current_files.out -y | grep -e "<" | awk -F " " '{ print $1 }' > difference.out
cat difference.out | tr -d '\r' > difference.out
if [ -z "`cat difference.out`" ]; then
	echo "No new files created"
else
	echo "Replicating new files in local server"
	# for file in `cat difference.out`; do cp p "./dummy_remote/$file" ./dummy_data/ ; done
	files=""
	if [ -z "`cat difference.out | tail -n+2 `" ]; then
		echo "Replicating new file in local server"
		echo "File copied :"
		for file in `cat difference.out`;do printf "$file \n"; sshpass -p $password scp -p  $username@$server:$remote_path/$file "data/"; done
	else
		echo "Replicating new files in local server"
		echo "Files copied :"
		for file in `cat difference.out`;do printf "$file \n"; files="$files$file,"; done
		files=`echo ${files%?}`
		sshpass -p $password scp -p  $username@$server:$remote_path/{$files} "data/"
	fi
fi	
# rm difference.out
printf "\n"