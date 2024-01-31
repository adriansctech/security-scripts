#!/bin/bash
ip=$@

# WIRESHARK
# YOU CAN CHECK ALL TRAFFIC GENERATED WITH THIS SCRIPT USING THIS FILTER "ip.dst == $ip"

if [ $#  -gt 0 ]; then 	# Check if arguments exists.
	echo "** SCANING ALL SERVICES **"
	nmap -sV -Pn $ip | tee "${1}-ALL-SERVICES.txt";
	
	# CHECK IF HTTP SERVICE IS UP
	if grep -q "http" "${1}-ALL-SERVICES.txt"; then
		echo "** SCANING HTTP WITH SCRIPT HTTP-ENUM **"
	    nmap -T4 -sV --script http-enum $ip | tee "${1}-HTTP-ENUM-DIRS.txt";
	    echo "** SCANING HTTP WITH SCRIPT HTTP-METHODS **"
	    nmap -T4 --script http-methods $ip | tee "${1}-HTTP-METHODS.txt";
	fi

	# CHECK IF FTP SERVICE IS UP
	if grep -q "ftp" "${1}-ALL-SERVICES.txt"; then
		echo "** SCANING FTP WITH SCRIPT FTP-ANON **"
		nmap -T4 --script ftp-anon $ip | tee "${1}-FTP-ANON.txt";

		# EXPERIMENTAL
		#nmap -T4 --script ftp-anon,ftp-bounce,ftp-libopie,ftp-proftpd-backdoor,ftp-vsftpd-backdoor,ftp-vuln-cve2010-4221,tftp-enum $ip

		# UNCOMMENT NEXT LINE IF YOU WANT TO DO THIS, BRUTE FORCE
		# sudo nmap --script ftp-brute -p 21 $ip
	fi

	# CHECK IF SMB SERVICE IS UP
	if grep -q "smb" "${1}-ALL-SERVICES.txt"; then
		echo "** SCANING SMB WITH SCRIPT SMB OS DISCOVERY **"
		nmap -T4 --script smb-os-discovery.nse $ip | tee "${1}-SMB-OS-DISCOVERY.txt";
		# IF VICTIM IS UNIX SYSTEM, execute enum4linux
		if grep -q "Unix" "${1}-ALL-SERVICES.txt"; then
			echo "** EXECUTING ENUM4LINUX **"
			enum4linux $ip | tee "${1}-ENUM-FOR-LINUX.txt";
		fi
	fi

	# CHECK IF SSH SERVICE IS UP
	if grep -q "ssh" "${1}-ALL-SERVICES.txt"; then
		echo "** SCANING SSH WITH SCRIPT SSH AUTH METHODS**"
		nmap -T4 -p 22 --script ssh-auth-methods $ip | tee "${1}-SSH-AUTH-METHODS.txt";

		# EXPERIMENTAL
		# nmap -sV -Pn -vv -p 22 --script ssh-auth-methods,ssh-brute,ssh-hostkey,ssh-publickey-acceptance,ssh-run,ssh2-enum-algos,sshv1 $ip
		
		# UNCOMMENT NEXT LINE IF YOU WANT TO DO THIS, BRUTE FORCE
		# nmap -p 22 --script ssh-brute $ip
	fi

	# CHECK IF MYSQL SERVICE IS UP
	if grep -q "mysql" "${1}-ALL-SERVICES.txt"; then
		echo "** SCANING MYSQL WITH SCRIPT MYSQL INFO**"
		nmap -T4 -p 3306 --script mysql-info $ip | tee "${1}-MYSQL-INFO.txt";
		echo "** SCANING MYSQL WITH SCRIPT MYSQL DATABASES INFO**"
		nmap -T4 -p 3306 --script mysql-databases $ip | tee "${1}-MYSQL-DATABASES.txt";
		echo "** SCANING MYSQL WITH SCRIPT MYSQL USERS INFO**"
		nmap -T4 -p 3306 --script mysql-users $ip | tee "${1}-MYSQL-USERS.txt";
		echo "** SCANING MYSQL WITH SCRIPT MYSQL EMPTY PASSWORDS**"
		nmap -T4 -p 3306 --script mysql-empty-password $ip | tee "${1}-MYSQL-EMPTY-PASSWORDS.txt";
		# UNCOMMENT NEXT LINE IF YOU WANT TO DO THIS, BRUTE FORCE
		# nmap -p 3306 --script mysql-brute $ip 
	fi

	timestamp=$(date +"%s")
	# CREATE TAR FILE WITH ALL RESULTS
	tar -cvf "$timestamp-${1}-NMAP-SCAN-RESULTS.tar" *.txt &&

	# GENERATE HASH FILE WITH TAR RESULTS	
	echo "md5 $(md5sum "$timestamp-${1}-NMAP-SCAN-RESULTS.tar" | awk '{ print $1 }')" >> "$timestamp-${1}-NMAP-SCAN-RESULTS.hash"
	echo "sha256 $(sha256sum "$timestamp-${1}-NMAP-SCAN-RESULTS.tar" | awk '{ print $1 }')" >> "$timestamp-${1}-NMAP-SCAN-RESULTS.hash"

	# REMOVE ALL TXT PREVIOUSLY FILES
	rm -rf *.txt
	echo "HASH FOR $timestamp-${1}-NMAP-SCAN-RESULTS.tar:"
	cat "$timestamp-${1}-NMAP-SCAN-RESULTS.hash"

else
	echo "no valid IP argument, close execution"
fi