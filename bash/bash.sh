#!/bin/bash

emailFrom=$1
heloDomain=$2

logfile=_log
invalidDomainsFile=_invalid_domains

count=0

function verifyEmailsFromFile {
	filename=$1
    domain=${filename#domain_}
	mxStr=$(dig $domain mx +short)

	IFS=' ' read -r -a mxArray <<< "$mxStr"

	if [ ${#mxArray[@]} -lt 2 ]		#< 2
	then
	    echo "ERROR : No suitable MX records found : $domain"
	    printf "$domain : no MX records\n" >> $invalidDomainsFile
        return 3
	fi

	mxAddr=${mxArray[1]}
	mxAddr=${mxAddr%.}		# remove last point '.'
	echo $mxAddr
	#printf "domain: $domain\n" >> $logfile
	printf "mx: $mxAddr\n" >> $logfile

	expect telnetExpect.sh $filename $domain $mxAddr $emailFrom $heloDomain
	res=$?

	if [ $res -eq 1 ]
		then
			((count=count+1))

			if [ $count -lt 6 ]
				then
					printf "telnet timeout $count\n" >> $logfile
                    printf "timeout $count... file: $filename"

					verifyEmailsFromFile $filename
					res=$?
					return $res
			fi
	fi

	#while [ $res -eq 1 ]
	#do
	#    printf "telnet timeout\n" >> $logfile
	#    echo "timeout... file: $filename"
	#    expect telnetExpect.sh $filename $domain $mxAddr
	#    res=$?
	#done

	count=0
	printf "telnet finished\n" >> $logfile

	return $res
}




# Get file list
IN_FILES=($(ls domain_*))
qty=${#IN_FILES[@]};

for filename in "${IN_FILES[@]}"
do
	printf "\n\n\n\n\n.......START file: $filename\n"
	printf ".......START file: $filename\n" >> $logfile

	verifyEmailsFromFile $filename
	res=$?
	printf "\nverifyEmailsFromFile returned: $res\n"
	printf ".......DONE file: $filename\n"

	printf ".......DONE file: $filename\n\n\n" >> $logfile

	# Remove file
	if [ $res -eq 0 ]
    	then
    	    rm -f $filename
    fi

	# Log timeout
    if [ $res -eq 1 ]
        then
       		printf "$filename : timeout : $res\n\n\n" >> _problem_domains
	fi
done

printf "ALL FILES FINISHED\n"