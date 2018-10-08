#!/bin/bash

	red=$(tput bold;tput setaf 1)            
green=$(tput setaf 2)                    
	yellow=$(tput bold;tput setaf 3)         
fawn=$(tput setaf 3)
	blue=$(tput bold;tput setaf 4)           
purple=$(tput setaf 5)
	pink=$(tput bold;tput setaf 5)           
	cyan=$(tput bold;tput setaf 6)           
gray=$(tput setaf 7)                     
	white=$(tput bold;tput setaf 7)          
normal=$(tput sgr0)                      

create_rules()
{
	local sep=`echo -e '\001'` # use \001 as a separator instead of '/'

		while [ -n "$1" ] ; do
			local color=${!1}
	local pattern="$2"
		shift 2

		rules="$rules;s$sep\($pattern\)$sep$color\1$normal${sep}g"
		done
}

print_colors()
{
	msg="$@"
		while [ -n "$1" ] ; do
			local patterns="$patterns $1 $1"
				shift 1
				done
				create_rules $patterns
				echo "$msg" | sed -u -e "$rules"
}

DEFAULTLOG=""

if [ "$1" == "-h" ]; then
print_colors red green yellow fawn blue purple pink cyan gray white normal
exit 0
elif [ "$1" == "-l" ]; then
DEFAULTLOG="red \[ERR\] yellow \[WARN\] green \[INFO\] white \[DEBUG\] "
shift
fi

create_rules $DEFAULTLOG"$@"
#stdbuf -o0 -i0 sed -u -e "$rules"
sed -u -e "$rules"


