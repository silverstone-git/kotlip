#!/bin/sh

contains_string() {
    substring=$1
    string=$2
    return $(expr index "$substring" "$string")
}

carry_on() {
    contflag=1
    echo "$line" >> tempfile.kts
}

is_final_line() {
    lastline=0
    myline="$1"
    tmp="$myline"
    dquote_counter=0
    squote_counter=0
    c=0
    while [ $c -lt ${#myline} ] ;
    do
        rest=${tmp#?}   # the original string without the first character
        first=${tmp%$rest}  # the first character of the iteration

        # the //<sp> replaces all spaces to nothing, thus leaving us with non-blank or nothing, which,
        # is made non-blank forcefully because there are binary operators in the following lines, which
        # would've made it look like binary operator 1 operand if unattended
        if [ -z ${first// } ]; then
            #echo "Found a space or an unset, setting first to x"
            first="x"
        fi

        # comparing to confirm existence of quotes
        #echo "first was: $first"
        if [ $first = "'" ]; then
            squote_counter=$(echo "$squote_counter+1" | bc -l )
        fi
        if [ $first = '"' ]; then
            dquote_counter=$(echo "$dquote_counter+1" | bc -l )
        fi

        # if a semicolon is found, and quotes are closed, ie semicolon is outside quotes, it returns 1
        if [ $first = ';' ]; then
            if [ $(expr $squote_counter % 2) -eq 0 ]; then
                if [ $(expr $dquote_counter % 2) -eq 0 ]; then
                    #echo "all conditions match for lastline, flagging and breaking the loop.."
                    lastline=1
                    break
                fi
            fi
        fi
        tmp=$rest   # the string gets stripped from left on each iteration so that each first char is up for manipulation
    c=$(echo "$c+1" | bc)
    done

    # the default option, ie, if all conditions leading up to returning 1 were false, is 0
    return $lastline
}

contflag=0

echo
echo "Kotlin Interpretor 1.1 by Aryan Sidhwani"
echo "Type 'exit;' to exit"
echo

while true
do

if [ $contflag -eq 0 ]; then
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

# Checks if ; exists in entered line and if it does, checks if the quotes are closed
# and then executes the script and deletes the temporary file, otherwise adds the line to the temp file

contains_string ";" "$line"
if [ $? -eq 1 ]; then

    is_final_line "$line"
    if [ $? -eq 1 ];
    then
        #echo  "...reached script run section..."
        echo "$line" >> tempfile.kts
        #echo "cat-ting the tempfile: "
        #echo
        #cat tempfile.kts
        kotlinc -script tempfile.kts

        if [ -f "tempfile.kts" ]; then
    	    rm tempfile.kts
	    fi
        contflag=0
    else
        carry_on
    fi
else
    carry_on 
fi
#echo "contflag at the end of main loop is: $contflag"
done
