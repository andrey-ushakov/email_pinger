#!/bin/bash

pathBase=$1

START_TIME=$(date +%s)

logfile=${pathBase}_log
invalidDomainsFile=${pathBase}_invalid_domains
problem_domains=${pathBase}_problem_domains


count=1

function verifyEmailsFromFile {
	filename=$1

    domain=${filename#${pathBase}domain_}
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
	printf "telnet: $mxAddr\n" >> $logfile

	expect telnetExpect.sh $filename $domain $mxAddr $pathBase
	res=$?

	if [ $res -eq 1 ]
		then
			((count=count+1))
			printf "telnet timeout. Restart $count \n" >> $logfile
            printf "telnet timeout. Restart $count \n"

			if [ $count -lt 4 ]
				then
					verifyEmailsFromFile $filename
					res=$?
					return $res
			fi
	fi

	count=1
	printf "telnet finished\n" >> $logfile

	return $res
}




# Get file list
IN_FILES=($(ls ${pathBase}domain_*))
qty=${#IN_FILES[@]};

ind=0
for filename in "${IN_FILES[@]}"
do
	((ind++))
	printf "\n\n\n\n\n.......START file ($ind / $qty): $filename\n"
	printf ".......START file ($ind / $qty): $filename\n" >> $logfile

	verifyEmailsFromFile $filename
	res=$?

	# Remove file
	if [ $res -eq 0 ]
    	then
    	    rm -f $filename
    fi

	# Log timeout
    if [ $res -eq 1 ]
        then
       		printf "$filename : Timeout. Returned code : $res\n\n\n" >> $problem_domains
	fi

	# Log
	if [ $res -eq 0 ]
        then
       		printf "Success (All emails was processed)\n" >> $logfile
	fi
    if [ $res -eq 1 ]
        then
       		printf "Domain skipped (Timeout)\n" >> $logfile
	fi
	if [ $res -eq 2 ]
        then
       		printf "Domain skipped (Ip blocked)\n" >> $logfile
	fi
	if [ $res -eq 3 ]
        then
       		printf "Domain skipped (torsocks error)\n" >> $logfile
	fi
	if [ $res -eq 4 ]
        then
       		printf "Domain skipped (Cannot find your hostname)\n" >> $logfile
	fi
	if [ $res -eq 5 ]
        then
       		printf "Domain skipped (Connection closed by foreign host)\n" >> $logfile
	fi
	if [ $res -eq 6 ]
        then
       		printf "Domain skipped (Protocol error)\n" >> $logfile
	fi


	printf "\nverifyEmailsFromFile returned: $res\n"
	printf "..............DONE file..............\n"

	printf "..............DONE file..............\n\n\n" >> $logfile
done

chmod 777 $logfile
chmod 777 $invalidDomainsFile
chmod 777 $problem_domains
chmod 777 ${pathBase}_valid_emails
chmod 777 ${pathBase}_invalid_emails

printf "done" >> ${pathBase}_done
chmod 777 ${pathBase}_done

printf "ALL FILES FINISHED\n"

#time
END_TIME=$(date +%s)
DIFF=$(( END_TIME - $START_TIME ))
printf "Execution time: $DIFF seconds\n"
printf "Execution time: $DIFF seconds\n" >> $logfile