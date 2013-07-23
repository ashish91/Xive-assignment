# set -x
touch remote_files.out
# data=`sshpass -p 'password' ssh username@dserver.com 'cd /home/data; ls -l | cut --complement -f 3,4 -d " " '`
data=`ls dummy_remote -l | cut --complement -f 3,4 -d " " | tail -n+2`  
echo "$data" > remote_files.out
mtime=`stat -c%Y dummy_remote/*`
echo "$mtime" > remote_time.out
paste remote_files.out remote_time.out > remote_files_time.out
ls dummy_data/ -l | cut --complement -f 3,4 -d " " | tail -n+2 > current_files.out
cat current_files.out
stat -c%Y dummy_data/* > current_time.out
paste current_files.out current_time.out > current_files_time.out
paste remote_files_time.out current_files_time.out  | awk -F " " '{if($8>$16){print $7}}' > difference.out
# diff current_files.out remote_files.out -y > difference.out
# cat difference.out
if [ -z "`cat difference.out`" ]; then
	echo "No files to sync"
else
	# diff --changed-group-format='%>' --unchanged-group-format='' current_files.out remote_files.out | awk '{print $7}' > difference.out
	for file in `cat difference.out`; do cp -pv "./dummy_remote/$file" ./dummy_data/ ; done
	echo "files up to date"
fi