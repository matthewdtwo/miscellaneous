#!/bin/bash
#
# Script to find media files and their space consumption
#
#

imagetypes="png jpg gif bmp"
movtypes="mov mp4 wmv avi flv"
doctypes="doc docx xls xlsx ppt pptx csv"
misctypes="mp3 wav m4a"

filetypes="$imagetypes $movtypes $doctypes $misctypes"

total=0

if [ -z "$1" ]; then
	# print usage
	echo "usage: $0 <directory>"
	exit 1
fi

if [ ! -d "$1" ]; then
	#not a directory
	echo "$1 is not a directory"
	exit 1
fi

if [ -h "$1" ]; then
	# path is symbolic link
	# confirm scanning
	echo "$1 is a symbolic link"
	echo 
	echo  `ls -l $1`
	echo -n "continue? (y/n): "
	read continueit
	if [ $continueit ]; then
		if [ "$continueit" == "n" ]; then
			echo "user aborted"
			exit 1
		elif [ "$continueit" != "y" ]; then
			echo "unknown answer $continueit"
			echo "aborting"
			exit 1
		fi
	else
		echo "aborting"
		exit 1
	fi
fi

# start scanning
echo "Scanning $1 for media files"
echo

for files in imagetypes movtypes doctypes misctypes; do
	size=0
	for ftype in ${!files}; do 
		res=`/usr/bin/find $1 -type f -iname *.$ftype | wc`

		for value in `/usr/bin/find $1 -type f -iname *.$ftype -exec du -k {} + | cut -f1`; do
			size=`expr $size + $value`
		done

		res=`echo $res | cut -d" " -f1`
		echo "$ftype: $res found"
	done
	echo "$files: $((size/1024))M"
	echo
	total=`expr $total + $size`
done

echo
total=$((total/1024))

echo "total: ${total}MB"

exit 1


