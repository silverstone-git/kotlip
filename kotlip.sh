#!/bin/bash

contains_string() {
    substring=$1
    string=$2
    return $(expr index "$substring" "$string")
}

contflag=0
echo -e "\nPlease avoid using ';' inside strings if there is no ';' in the rest of the command \n"

while :
do

if [ $contflag = 0 ]; then
    read -p "kt>> " line
else
    read -p "> " line
fi

# The program will exit if 'exit;' is written

if [ "$line" = "exit;" ]; then
	if [ -f "tempfile.kts" ]; then
		rm tempfile.kts
	fi
    break
fi

# Checks if ; is present in line treats it as last line of the code

contains_string ";" "$line"
if [ $? = 1 ]; then
    #echo  "....reached script run section...."
    echo "$line" >> tempfile.kts
    #cat tempfile.kts
    kotlinc -script tempfile.kts
    if [ -f "tempfile.kts" ]; then
    	rm tempfile.kts
	fi
    contflag=0
else
    contflag=1
    echo "$line" >> tempfile.kts
    
fi
done
