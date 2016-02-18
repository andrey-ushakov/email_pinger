#!/bin/bash

pathBase=$1

logfile=${pathBase}_log
invalidDomainsFile=${pathBase}_invalid_domains
problem_domains=${pathBase}_problem_domains

printf "$logfile\n"
printf "$invalidDomainsFile\n"
printf "$problem_domains\n"

#logfile=$pathBase$logfile
#invalidDomainsFile=$pathBase$invalidDomainsFile
#problem_domains=$pathBase$problem_domains


count=0

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
	printf "mx: $mxAddr\n"
	#printf "domain: $domain\n" >> $logfile
	printf "mx: $mxAddr\n" >> $logfile

	expect telnetExpect.sh $filename $domain $mxAddr $pathBase
	res=$?

	if [ $res -eq 1 ]
		then
			((count=count+1))

			if [ $count -lt 4 ]
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
IN_FILES=($(ls ${pathBase}domain_*))
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
       		printf "$filename : timeout : $res\n\n\n" >> $problem_domains
	fi
done

printf "ALL FILES FINISHED\n"