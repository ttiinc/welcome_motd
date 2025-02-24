#!/bin/bash

export CRED='\033[0;31m'
export CDEF='\033[0m'
export CYELLOW='\033[1;33m'
export CGREEN='\033[0;32m'
export CBLINK='\033[5m'
export CBOLD='\033[1m'
export CINV='\033[7m'

hostname=$(hostname)

# Setzen des Prefix von LAN-Interfaces, z. B. wenn diese nicht mit "eth" sondern mit "end" beginnen. Kann auch eine regexp sein.
export IF_PREFIX='ens'

function fpblank(){
	export CC=${CGREEN}
	echo ""
}

function fpram(){
	export CC=${CGREEN}
	MAX=$(free -h | grep Mem | xargs | sed 's/ /\//g' | cut -d/ -f 2)
	USE=$(free -h | grep Mem | xargs | sed 's/ /\//g' | cut -d/ -f 3)
	PCT=$(awk "BEGIN {print ${USE::-2}/${MAX::-2}}")
	if [ $(awk "BEGIN {print (${PCT}>=0.7)}") -eq 1 ]
	then
		CC=${CRED}
	elif [ $(awk "BEGIN {print (${PCT}>=0.5)}") -eq 1 ]
	then
		CC=${CYELLOW}
	fi
	echo -e "RAM (use/max): ${CC}${CBOLD}${USE}/${MAX}${CDEF}"
}

function fpstorage(){
	export CC=${CGREEN}
	STORAGE=$(df -h | grep -E "/$" | xargs | sed 's/ /\//g' | cut -d/ -f5,6)
	MAX=$(echo ${STORAGE} | cut -d/ -f1)
	USE=$(echo ${STORAGE} | cut -d/ -f2)
	PCT=$(df -h | grep -E "/$" | xargs | cut -d " " -f 5 | sed 's/%//g')
	if [ ${PCT} -ge 80 ]
	then
		CC=${CRED}
	elif [ ${PCT} -ge 60 ]
	then
		CC=${CYELLOW}
	fi
	echo -e "Disk (use/max): ${CC}${CBOLD}${USE}/${MAX}${CDEF}" 
}

function fpwarning(){
	export CC=${CGREEN}
	echo -e "${CRED}Unauthorized access prohibited! This system is actively monitored.${CDEF}"
}

function fpuptime(){
	export CC=${CGREEN}
	UPTIME=$(uptime -p | sed 's/up //g')
	DAYS=$(uptime -p | cut -d ' ' -f 2)
	if [ ${DAYS} -ge 100 ]
	then
		CC=${CRED}
	elif [ ${DAYS} -ge 60 ]
	then
		CC=${CYELLOW}
	fi
	echo -e "Uptime: ${CC}${CBOLD}${UPTIME}${CDEF}"
}

function fploadavg(){
	export CC=${CGREEN}
	MAX=$(nproc).0
	AVG=$(cat /proc/loadavg | cut -d" " -f1)
	if [ $(awk "BEGIN { print (${AVG}>=3.5)}") -eq 1 ]
	then
		CC=${CRED}
	elif [ $(awk "BEGIN { print (${AVG}>=3.0)}") -eq 1 ]
	then
		CC=${CYELLOW}
	fi
	echo -e "Load (avg/max): ${CC}${CBOLD}${AVG}/${MAX}${CDEF}"
}

# function fcheckreboot(){
# 	export CC=${CGREEN}
# 	ls /var/run/reboot-required > /dev/null 2>&1
# 	if [ $? -eq 0 ]; 
# 	then
# 		echo ""
# 		echo -e "${CINV}System reboot required!${CDEF}"
# 	fi
# }

function fpinterfaces(){
	INTERFACES=$(ip l | sort -n | grep -Ee " ${IF_PREFIX}" | cut -d: -f 2 | xargs)
	for IF in ${INTERFACES}
	do
		IP=$(ip a l dev ${IF} | grep -e "inet " | xargs | cut -d' ' -f2)
		echo "IP (${IF}): ${IP}"
	done
}

LINE1="Welcome, $USER"
#LINE1="Willkommen, $(getent passwd $USER | cut -d: -f5)"
LINE2=$(for CHAR in $(seq 2 $(echo $LINE1 | wc -m)); do printf '-'; done)
LINE3="Hostname: ${CGREEN}$hostname"

fpblank
echo -e "${CBOLD}$LINE1${CDEF}"
echo -e "${CBOLD}$LINE2${CDEF}"
fpblank
echo -e "${CBOLD}$LINE3${CDEF}"
fpblank
fpram
fpstorage
fpuptime
fploadavg
#fcheckreboot
fpblank
fpinterfaces
fpblank
fpwarning
fpblank
