#!/bin/bash

# WEBSITE USED FOR SCRAPING
# https://www.webberinsurance.com.au/data-breaches-list#twentyone

# High level requirements:
    # User wants to be able to search by month, year or both.
    # Needs menu options to loop through and prompt user re-entry if incorrect.
    # Need results to be visualised clearly for report creations and trend analysis.


## FUNCTIONS ##
# Blocking functions to gether to have clear location in code

# Function to call on valid months
function month_list() {
    echo "January"
    echo "February"
    echo "March"
    echo "April"
    echo "May"
    echo "June"
    echo "July"
    echo "August"
    echo "September"
    echo "October"
    echo "November"
    echo -e "December\n"
}

# Function to call on years wanted.
# Another program which is built on Pearl is used as basis for years. 
function year_list() {
years_avail=$(<years.txt)
echo "$years_avail"
echo ""
}

# Function to display text content in clear database/table format
function awk_format() {
    awk 'BEGIN {
    FS=":";
    print "____________________________________________________________________________________";
    print "| \033[80mEntity\033[0m                                                      | \033[34mMonth\033[0m      | \033[34mYear\033[0m  |";
    print "------------------------------------------------------------------------------------ ";
    }
    {
     printf("| \033[33m%-59s\033[0m | \033[35m%-10s\033[0m | \033[35m%-1s\033[0m |\n", $1, $2, $3);   
    }
    END {
        print("____________________________________________________________________________________");
        printf "There are %d major cyber breaches matching your search parameters!\n", NR;

    }' 
}

## VARIABLES ##

# Colour variables - Have listed common colours to call on in future developments
black='\033[30m'
red='\033[31m'
green='\033[32m'
brown='\033[33m'
blue='\033[34m'
purple='\033[35m'
cyan='\033[36m'
grey='\033[37m'
bold='\033[1m'
reset_colour='\033[0m'

## TEXT PARSING ##

# Curl to obtain html information of website
curl https://www.webberinsurance.com.au/data-breaches-list#twentyone > Site1.txt

# Grep command to gather desired information including the entity, month and year.
Heading="$(grep "^<h3>" Site1.txt)"

# Text scrubbing through SED commands to remove unwanted characters, old webpage formats etc.
Heading_Info=$(echo "$Heading" | sed 's~<h3>~~' )
Text_scrub=$(echo "$Heading_Info" | sed 's~Site1.txt:<h3>~~' | sed -r 's~(.*)&#8211;~\1:~' | sed 's~</h3>~~' | sed 's~&#8211;~~g' | sed 's~&#8217;~~' | sed 's~Typeform] |~:~' | sed 's~amp;~~')
#echo "$Text_scrub" > Awk_test.txt

# Some more hard coded scrubbing for particular examples with outdated format and pattern
# Added colons to clearly seperate columns
Month_scrub=$(echo "$Text_scrub" | sed -r 's~(.*) 20~\1: 20~' | sed 's~2018 Update~2018~' | sed 's~2020 Update~2018~' | sed 's~2017, reported ~~' | sed -zE 's~[[:space:]]([:])~\1~g' | sed -zE 's~\xc2\xa0~~g' | sed 's~^.*FitnessPal App~Under Armours MyFitnessPal App~' ) > Awk_test.txt
echo "$Month_scrub"  > Awk_test.txt

# Cleaning up file created
rm Site1.txt

## MENU SELECTION ##
# Menu options controlled through while loop
while :;  
do
    echo -e "\nDo you want to investigate cyber security breaches by"
    echo "1- Month only"
    echo "2- Year only"
    echo "3- Month and year"
    echo "9- Exit" 
    read -p "Enter the menu number option you want to select: " main_menu_selection

    ## USER INPUT DESIGN ##
    # Based on user search parameters, case statement dictatessearch performed
    case $main_menu_selection in
        [1] )
            while :;  
            do
                echo -e "\nYou have selected option $main_menu_selection."
                echo "Available months are:"
                month_list
                read -p "Type the month you want to search: " month_selection
                ## SEARCH OF DATABASE ##
                # If statement does insensitive search of user input month to data collected
                if [[ "${Month_scrub,,}" == *"${month_selection,,}"* ]]; then 
                    grep -i "$month_selection" Awk_test.txt | awk_format
                    # Cleanup of file used in script
                    rm Awk_test.txt
                else
                    echo -en "$red"
                    echo -e "\nMonth is not found or incorrect format \n"
                    echo -en "$reset_colour"
                    break
                fi
                exit 0
            done
            ;;
        [2] )
            while :; 
            do
                echo -e "\nYou have selected option $main_menu_selection."
                echo "Available years are:"
                year_list
                read -p "Type the year you want to search: " year_selection
                # If statement does insensitive search of user input month to data collected
                if [[ "$Month_scrub" == *"$year_selection"* ]]; then 
                    grep -i "$year_selection" Awk_test.txt | awk_format
                    # Cleanup of file used in script
                    rm Awk_test.txt
                else
                    echo -en "$red"
                    echo -e "\nYear is not found or incorrect format \n"
                    echo -en "$reset_colour"
                    break
                fi
                exit 0
            done
            ;;
        [3] )
            while :; 
            do
            echo -e "\nYou have selected option $main_menu_selection."
            echo "Available months are:"
            month_list
            read -p "Type the month you want to search: " month_selection
            echo "Available years are:"
            year_list
            read -p "Type the year you want to search: " year_selection
            # If statement does insensitive search of user input month and year to data collected
            if [[ "$Month_scrub" == *"$year_selection"* ]] && [[ "${Month_scrub,,}" == *"${month_selection,,}"* ]]; then
                grep -i "$year_selection" Awk_test.txt | grep -i "$month_selection" | awk_format
                # Cleanup of file used in script
                rm Awk_test.txt
            else
                    echo -en "$red"
                    echo -e "\nYear and month is not found or incorrect format \n"
                    echo -en "$reset_colour"
                    break
                fi
                exit 0
            done
            ;;
        [9] )
            # Option to exit the program and break the loop
            echo -e "\nYou have selected menu option $main_menu_selection. See you next time"
            # Cleanup of file used in script
            rm Awk_test.txt
            break
            ;;
        *   ) 
            echo -en "$red"
            echo -e "Invalid number, please input a number from the options available\n"
            echo -en "$reset_colour"

    esac
done
exit 0



# REFERENCES

# SED escape variable
# https://www.unix.com/shell-programming-and-scripting/71927-sed-how-escape-variable-number-slash.html
# https://unix.stackexchange.com/questions/32907/what-characters-do-i-need-to-escape-when-using-sed-in-a-sh-script


# REGEX syntax
# https://www.gnu.org/software/sed/manual/html_node/Regular-Expressions.html

# GREP, AWK, SED BASICS
# https://www-users.york.ac.uk/~mijp1/teaching/2nd_year_Comp_Lab/guides/grep_awk_sed.pdf
# https://www.endpoint.com/blog/2017/01/using-awk-to-beautify-grep-searches/
# https://stackoverflow.com/questions/20080098/how-to-run-grep-inside-awk
# https://unix.stackexchange.com/questions/229387/passing-the-results-of-awk-command-as-a-parameter

# SED REPLACE LAST OCCURANCE
# https://linuxhint.com/use-sed-replace-last-occurrence/
# https://unix.stackexchange.com/questions/187889/how-do-i-replace-the-last-occurrence-of-a-character-in-a-string-using-sed

# SED REMOVE WHITESPACE
# https://linuxhint.com/sed_remove_whitespace/

# SED REMOVE HEXIDECIMAL CHARACTERS
# https://askubuntu.com/questions/357248/how-to-remove-special-m-bm-character-with-sed
# https://www.unix.com/unix-for-dummies-questions-and-answers/98893-how-delete-all-character-before-certain-word.html

# NESTED WHILE LOOPS
# https://tldp.org/LDP/Bash-Beginners-Guide/html/sect_09_02.html

# IGNORING CASE IN IF STATEMENT
# https://stackoverflow.com/questions/1728683/case-insensitive-comparison-of-strings-in-shell-script

# DELETE FILE AT END OF SCRIPT
# https://linuxhint.com/delete_file_bash/

# GIT update commands
# https://git-scm.com/docs/git-commit