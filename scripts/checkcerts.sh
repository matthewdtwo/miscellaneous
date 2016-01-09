#!/bin/bash
#
#
# Check expiration date of certificates and alert upon upcoming expiration.
#
# This script will grab the SSL certificate from the website listed in a file passed as an argument, get the expiration date of that certificate, and send an email alert to the emails listed in $to_email if the certificate expires in less time than $expthresh

# websites should be running SSL on port 443 - other ports are not supported yet
# websites entries should only contain the hostname - no https:// or anything prefacing it

# the list of websites passed should be in the following format
#
# ------------------------------------------
# |                                        |
# | # comments start with a # sign         |
# | www.yourwebsite.com                    |
# | www.yourotherwebsite.com               |
# |                                        |
# ------------------------------------------

# override system Timezone since cert timestamp is in GMT
export TZ="GMT"

# configuration variables used for cleaning up output
min_sec="60"
hour_sec=$((min_sec*60))
day_sec=$(($hour_sec*24))
week_sec=$(($day_sec*7))
year_sec=$((week_sec*52))



# set the TO email field here - separate multiples with a space
to_email="itadministration-linux@mbsbooks.com"

#set the threshold here - the threshold is in seconds, and the variables above can be used as shown in the current value (4 weeks) for simplification

expthresh=$((4*week_sec)) # alert four weeks before
#expthresh=$((4*$year_sec)) # alert four years before - for testing purposes

echo "expthresh: $expthresh"

############### functions #########################

function getSites {
	for line in `grep -v ^# $1`; do
		echo "Checking cert for $line"
		site=$line
		openssl s_client -connect $line:443 > $line.acert </dev/null 2>/dev/null

		if [[ -r "$line.acert" ]]; then
			# cert exists, we grabbed something
			if [[ -n "`cat $line.acert`" ]]; then
				getcertdate $line.acert
				getdaysexp
			else
				echo "Failed to get cert!!"
				sendmsg "Failed to grab certificate for $line" "Something weird is happening dude. Better go check it out"
			fi
		
		else
			echo "Failed to get cert!!"
			sendmsg "Failed to grab certificates" "Something weird is happening dude. Better go check it out"
		fi
	done
}


function getcertdate {
	if [ -f $1 ]; then
		certdate=`openssl x509 -noout -in $1 -enddate | cut -c10-` # extract the certificate expiration date from the certificate
	else
		echo "An error has occured reading the certificate."
		exit 1
	fi
}

function sendmsg { # send email msg
		# usage 
		# sendmsg <subject> <body> 
        echo "$2" | mail -s "$1" $to_email

}

function getcurdate {
	today=`date +"%b %e %k:%M:%S %Y %Z"` # get current date in the format of month day 24-hour:minute:second 4-year timezone
}


function getdaysexp {

	if [[ -z $certdate &&  -z $today ]]; then # make sure that we got the cert date and todays date succcessfully

		echo "A variable is not set"
		if [[ -z $certdate ]]; then echo "Cert date not set"; fi
		if [[ -z $today ]]; then echo "Today not set"; fi

	else

		D1=`date +%s -d "$today"` # convert date to seconds so we can do math
		D2=`date +%s -d "$certdate"` # see above

		diff_sec=$(($D2-$D1)) # grab difference in seconds
		total_sec=$diff_sec # store for checking, the rest below is for formatting the time to human-readable 
							# since I personally have trouble figuring out how long 36720000 seconds is in my head

		num_years=$((diff_sec/$year_sec))
		diff_sec=$(($diff_sec%$year_sec)) # set diff_sec to leftovers

		num_weeks=$(($diff_sec/$week_sec))
		diff_sec=$(($diff_sec%$week_sec)) # set diff_sec to leftovers

		num_days=$(($diff_sec/$day_sec)) 
		diff_sec=$(($diff_sec%$day_sec)) # set diff_sec to leftovers

		num_hours=$(($diff_sec/$hour_sec)) # get number of hours
		diff_sec=$(($diff_sec%$hour_sec)) # set diff_sec to leftovers

		num_minutes=$(($diff_sec/$min_sec)) # divide remaining seconds by number of seconds in a minute
		num_secs=$(($diff_sec%$min_sec)); # down to smallest unit here


		echo -n "The certificate expires in " > atempfile1234

		if [ "$num_years" -gt "1" ]; then
				echo -n "$num_years years " >> atempfile1234
		elif [ "$num_years" -eq "1" ]; then
				echo -n "$num_years year " >> atempfile1234 
		fi 

		if [ "$num_weeks" -gt "1" ]; then
				echo -n "$num_weeks weeks " >> atempfile1234 
		elif [ "$num_weeks" -eq "1" ]; then
				echo -n "$num_weeks week " >> atempfile1234 
		fi 

		if [ "$num_days" -gt "1" ]; then
				echo -n "$num_days days " >> atempfile1234 
		elif [ "$num_days" -eq "1" ]; then
				echo -n "$num_days day " >> atempfile1234 
		fi 

		if [ "$num_hours" -gt "1" ]; then
				echo -n "$num_hours hours " >> atempfile1234 
		elif [ "$num_hours" -eq "1" ]; then
				echo -n "$num_hours hour " >> atempfile1234 
		fi 

		if [ "$num_minutes" -gt "1" ]; then
				echo -n "$num_minutes minutes " >> atempfile1234 
		elif [ "$num_minutes" -eq "1" ]; then
				echo -n "$num_minutes minute " >> atempfile1234 
		fi 

		if [ "$num_secs" -gt "1" ]; then
				echo "$num_secs seconds" >> atempfile1234 
		elif [ "$num_secs" -eq "1" ]; then
				echo "$num_secs second" >> atempfile1234 
		fi 


		if [[ "$total_sec" -lt "$expthresh" ]]; then
			echo "CERTIFICATE EXPIRING SOON"
			sendmsg "Certificate for $site expiring soon" "`cat atempfile1234`"
		fi

		cat atempfile1234 # cat the file so that it shows up in the log


	fi

}

function usage { # print usage if no website list provided
	echo "usage: $0 <website_list>"
	exit 1;
}

function cleanup {
	# clean up tempfiles after myself
	rm atempfile1234 # clean up formatted output
	for line in `grep -v ^# $1`; do
		rm $line.acert
	done
		

}

if [[ "$1" == "" ]]; then # if no website list is provided, run the usgae function
	usage
elif [[ ! -r "$1" ]]; then # if we can't read the file provided, error out
	echo "Error reading list from $1"
	exit 1;
else
	getSites $1 # pull list and grab certs for sites listed

#	cleanup $1
fi

