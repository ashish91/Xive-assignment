#####################default values########################################
password="<hidden>"
username="<hidden>"
server="<hidden>"
field_delim="|"
row_delim="\\n"
text_qualifier="\""
csv_path="input/"
curr_csv=`ls $csv_path -l | awk -F " " '{ print $9 }' | grep "current"`
curr_tb=${curr_csv%????}
curr_csv="$csv_path$curr_csv"
prev_csv=`ls $csv_path -l | awk -F " " '{ print $9 }' | grep "previous"`
prev_tb=${prev_csv%????}
prev_csv="$csv_path$prev_csv"
changes_table="changes"
database="<hidden>"
local_path="."
remote_path="<hidden>"
#####################parse command line arguments########################################

if [ "$#" -ne 0 ]; then
	while [ ! -z "$1" ]
	do
		case "$1" in
			-l) local_path="$2";;
			-o) remote_path="$2";;
			-p) password="$2" ;;
			-u) username="$2" ;;
			-s) server="$2" ;;
			-f) field_delim="$2";;
			-r) row_delim="$2";;
			-q) text_qualifier="$2";;
			-c) csv_path="$2";;
			-e) header="$2"; 
			curr_csv=`ls $csv_path -l | awk -F " " '{ print $9 }' | grep "current"`;
			curr_tb=${curr_csv%????};
			curr_csv="$csv_path$curr_csv";
			prev_csv=`ls $csv_path -l | awk -F " " '{ print $9 }' | grep "previous"`;
			prev_tb=${prev_csv%????};
			prev_csv="$csv_path$prev_csv";
			;;
			-d) database="$2";;
			-n) changes_table="$2";;
			-h) echo "Help not available";exit ;;
			*) printf "Error: You have typed an invalid option $1 \nThis script is protected by satan himself \nplease go home if you are thinking of breaking it";exit ;;
		esac
		shift
		shift
	done
fi

cd $local_path

bash sync_new_files.sh -p $password -u $username -s $server -o $remote_path
bash sync_modified_files.sh -p $password -u $username -s $server -o $remote_path
bash transfer.sh -p $password -u $username -s $server
echo "importing $curr_csv into $curr_tb"
python import.py -f $field_delim -r $row_delim -q $text_qualifier -d $database -e $header -t $curr_tb -c $curr_csv
echo "$curr_csv Imported !!!!"
echo "importing $prev_csv into $prev_tb"
python import.py -f $field_delim -r $row_delim -q $text_qualifier -d $database -e $header -t $prev_tb -c $prev_csv
echo "$prev_csv Imported !!!!"
echo "Changes between $curr_tb and $prev_tb is copied into $changes_table"
python changed_address.py -d $database -u $curr_tb -p $prev_tb -f $changes_table