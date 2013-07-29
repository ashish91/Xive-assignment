#!/bin/bash

if [ "$#" -ne 0 ]; then
	while [ ! -z "$1" ]
	do
		case "$1" in
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

#################### transfer two most recent files to input folder#########################################
echo "transferring most recent files to input folder "
printf "[Caution: all files from input folder will be deleted]\n"
rm input/*
# current=`ls -lt dummy_data | awk -F " " '{ print $9 }' | sort | tail -1 | sed 's/\r$//'`
current=`ls -lt data | grep -e "MITSUBISHI.*[0-9]\{8\}.*" | awk -F " " '{ print $9 }' | sort | tail -1 | sed 's/\r$//'`
echo $current
# cp -f "dummy_data/$current" "input/`echo $current | cut -c -33`_current.csv" 
cp -f "data/$current" "input/`echo $current | cut -c -33`_current.csv" 
# previous=`ls -lt dummy_data | awk -F " " '{ print $9 }' | sort |tail -2 | head -1 | sed 's/\r$//' `
previous=`ls -lt data | grep -e "MITSUBISHI.*[0-9]\{8\}.*" | awk -F " " '{ print $9 }' | sort |tail -2 | head -1 | sed 's/\r$//' `
echo $previous
# cp -f "dummy_data/$previous" "input/`echo $previous | cut -c -33`_previous.csv" 
cp -f "data/$previous" "input/`echo $previous | cut -c -33`_previous.csv" 
echo "Files sucessfully transferred"
printf "\n"