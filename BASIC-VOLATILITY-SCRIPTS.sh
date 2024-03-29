#!/bin/bash

# HOW TO USE
#./BASIC-VOLATILITY-SCRIPTS.sh MINAF-PC1.mem Win7SP1x64

memfile=$1
profile=$2

# TO CHECK CORRECT VALUES
#echo $memfile
#echo $profile

#PROCESSES AND DLLS SECTION
# PSSCAN
	echo "RUN PSSCAN"
	# https://github.com/volatilityfoundation/volatility/wiki/Command-Reference#psscan
	vol.py --profile=$profile -f $memfile psscan > PSCAN-$memfile.txt &&
# PSTREE
	echo "RUN PSTREE"
	# https://github.com/volatilityfoundation/volatility/wiki/Command-Reference#pstree
	vol.py -f $memfile --profile=$profile pstree > PSTREE-$memfile.txt &&
# PSLIST
	echo "RUN PSLIST"
	# https://github.com/volatilityfoundation/volatility/wiki/Command-Reference#pslist
	vol.py -f $memfile --profile=$profile pslist > PSLIST-$memfile.txt &&
# CMDSCAN
	echo "RUN CMDSCAN"
	# https://github.com/volatilityfoundation/volatility/wiki/Command-Reference#cmdscan
	vol.py -f $memfile --profile=$profile cmdscan > CMDSCAN-$memfile.txt &&
# HANDLESS
	echo "RUN HANDLESS"
	# https://github.com/volatilityfoundation/volatility/wiki/Command-Reference#handles
	vol.py -f $memfile --profile=$profile handles > HANDLESS-$memfile.txt &&

#NETWORKING SECTION
	# NETSCAN
	echo "RUN NETSCAN"
	# https://github.com/volatilityfoundation/volatility/wiki/Command-Reference#netscan
	vol.py -f $memfile --profile=$profile netscan > NETSCAN-$memfile.txt &&
	# CONNECTIONS
	echo "RUN CONNECTIONS"
	# https://github.com/volatilityfoundation/volatility/wiki/Command-Reference#connections
	vol.py -f $memfile --profile=$profile connections > CONNECTIONS-$memfile.txt &&

#FILESYSTEM
	# MBRPARSER
	echo "RUN MBRPARSER"
	# https://github.com/volatilityfoundation/volatility/wiki/Command-Reference#mbrparser
	vol.py -f $memfile mbrparser -H > MBRPARSER-$memfile.txt &&
	# MFTPARSER
	echo "RUN MFTPARSER"
	# https://github.com/volatilityfoundation/volatility/wiki/Command-Reference#mftparser
	vol.py -f $memfile mftparser > MFTPARSER-$memfile.txt &&

#KERNEL MEMORY AND OBJECTS SECTION
	# FILESCAN
	echo "RUN FILESCAN"
	# https://github.com/volatilityfoundation/volatility/wiki/Command-Reference#filescan
	vol.py -f $memfile --profile=$profile filescan > FILESCAN-$memfile.txt &&
	# DUMPFILES
	#echo "RUN DUMPFILES"
	# https://github.com/volatilityfoundation/volatility/wiki/Command-Reference#dumpfiles
	#vol.py -f $memfile dumpfiles -D output/ -r evt$ -i -S summary.txt > DUMPFILES-$memfile.txt &

#REGISTRY SECTION
	# HIVESCAN
	echo "RUN HIVESCAN"
	# https://github.com/volatilityfoundation/volatility/wiki/Command-Reference#hivescan
	vol.py -f $memfile --profile=$profile hivescan > HIVESCAN-$memfile.txt &&
	# HIVELIST
	echo "RUN HIVELIST"
	# https://github.com/volatilityfoundation/volatility/wiki/Command-Reference#hivelist
	vol.py -f $memfile --profile=$profile hivelist > HIVELIST-$memfile.txt &&

#Finally section
	timestamp=$(date +"%s")
	# CREATE TAR FILE WITH ALL RESULTS
	tar -cvf "$timestamp-${1}-$memfile-RESULTS.tar" *.txt &&

	# GENERATE HASH FILE WITH TAR RESULT
	echo "md5 $(md5sum "$timestamp-${1}-$memfile-RESULTS.tar" | awk '{ print $1 }')" >> "$timestamp-${1}-$memfile-RESULTS.hash"
	echo "sha256 $(sha256sum "$timestamp-${1}-$memfile-RESULTS.tar" | awk '{ print $1 }')" >> "$timestamp-${1}-$memfile-RESULTS.hash"

# OPTIONALLY PART
# REMOVE ALL TXT PREVIOUSLY FILES
	#rm -rf *.txt

# SAMPLE TO SCAN TEXT INSIDE .txt FILES
# grep "text" -C "filename"
