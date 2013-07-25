# set -x 

#####################copy all newly created files into local########################################
echo "Checking if new files were created at "
# data=`sshpass -p 'Password' ssh user@server.com 'cd /home/mitsudata; ls -ltr | cut --complement -f 3,4 -d " " | tail -n+2 | awk -F " " '{ print $7 }' '`
data=`ls dummy_remote -ltr | cut --complement -f 3,4 -d " " | tail -n+2 | awk -F " " '{ print $7 }' | sort`
echo "$data" > remote_files.out
ls dummy_data -ltr | cut --complement -f 3,4 -d " " | tail -n+2 | awk -F " " '{ print $7 }' | sort > current_files.out
diff remote_files.out current_files.out -y | grep -e "<" | awk -F " " '{ print $1 }' > difference.out
cat difference.out | tr -d '\r' > difference.out
if [ -z `cat difference.out` ]; then
	echo "No new files created"
else
	echo "Replicating new files in local server.com"
	for file in `cat difference.out`; do cp -pv "./dummy_remote/$file" ./dummy_data/ ; done
fi	
# rm difference.out
printf "\n"

##################### sync modified files from remote ###########################################################

echo "Checking whether files were modified..."
# data=`sshpass -p 'Password' ssh user@server.com 'cd /home/mitsudata; ls -l | cut --complement -f 3,4 -d " " | tail -n+2 '`
data=`ls dummy_remote -l | cut --complement -f 3,4 -d " " | tail -n+2`  
echo "$data" > remote_files.out
# mtime=`sshpass -p 'Password' ssh user@server.com 'cd /home/mitsudata; stat -c"%Y" ./* '`
mtime=`stat -c%Y dummy_remote/*`
echo "$mtime" > remote_time.out
paste remote_files.out remote_time.out > remote_files_time.out
ls dummy_data/ -l | cut --complement -f 3,4 -d " " | tail -n+2 > current_files.out
# ls data/ -l | cut --complement -f 3,4 -d " " | tail -n+2 > current_files.out
# stat -c%Y data/* > current_time.out
stat -c%Y dummy_data/* > current_time.out
paste current_files.out current_time.out > current_files_time.out
paste remote_files_time.out current_files_time.out  | awk -F " " '{if($8>$16){print $7}}' > difference.out
# diff current_files.out remote_files.out -y > difference.out
# cat difference.out
if [ -z "`cat difference.out`" ]; then
	echo "No files to sync"
else
	echo "Modified files are being copied"
	# diff --changed-group-format='%>' --unchanged-group-format='' current_files.out remote_files.out | awk '{print $7}' > difference.out
	for file in `cat difference.out`; do cp -pv "./dummy_remote/$file" ./dummy_data/; done
	echo "files up to date"
fi

printf "\n"

#################### transfer two most recent files to input folder#########################################
echo "transferring most recent files to input folder "
printf "[Caution: all files from input folder will be deleted]\n"
rm input/*
current=`ls -lt dummy_data | tail -n+2 | awk -F " " '{ print $9 }' | sort | tail -1 | sed 's/\r$//'`
echo $current
cp -f "dummy_data/$current" "input/`echo $current | cut -c -34`current.csv" 
previous=`ls -lt dummy_data | tail -n+3 | awk -F " " '{ print $9 }' | sort |tail -1 | sed 's/\r$//' `
echo $previous
cp -f "data/$previous" "input/`echo $previous | cut -c -34`previous.csv" 
echo "Files sucessfully transferred"
printf "\n"

##################### import the current and previous csv to MSSQL server.com 2008 ##########################################

python import.py