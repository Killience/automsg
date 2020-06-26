#####################################################################
# If on Mac, change MY_NUMBER, group names, and group numbers. 

#!/bin/bash
MY_NUMBER="+14074847571"
scriptName=msg.sh
#
# GROUPS, NAMES, and NUMBERS (like a sudo map)
ladies=("Shweta":"+1234")
family=("Shweta":"+1234" "Dad":"+765")
mates=("Kiron":"+1234" "Jeremy":"+222")
number_of_groups=3
# group 0=ladies 1=family 2=mates
#
# gounp_name=("Name":"+countryCodePhone_number" "Name"...and so on)
#
# to add a group, add info here under the last group and 
# advance number_of_groups + 1

############# Pick random Group and random Person #############
target_group=$[ RANDOM % number_of_groups ]

if   [ $target_group -eq 0 ]; then
  	person_index=$[$RANDOM % ${#ladies[@]}];
  	target_name=${ladies[person_index]}; 
elif [ $target_group -eq 1 ]; then 
  	person_index=$[$RANDOM % ${#family[@]}];
  	target_name=${family[person_index]};  
elif [ $target_group -eq 2 ]; then 
  	person_index=$[$RANDOM % ${#mates[@]}];
  	target_name=${mates[person_index]};
# .
# .
# elif [ $target_group -eq N ]; then 
#   	person_index=$[$RANDOM % ${#GROUPNAME[@]}];
#   	target_name=${GROUPNAME[person_index]};
else 
	echo "Error!"
	echo "Make sure you really have ${number_of_groups} groups?"
fi
###############################################################

name=${target_name%%:*}  # information preceding colon -> name:
number=${target_name#*:} # information following colon -> :number

###################   Messsage database  #######################
# Current hour
hourNow="$(date +%H)";

# shell will interpret hourNow as an octal number (with leading 0) 
# to avoid this, remove the leading zero using parameter expansion.
hourNow=${hourNow#0}

# add all time depended variables here
if (( hourNow >= 8 ))  && (( hourNow < 12 )); then
    time_of_day="morning";	HHH="have";	GGG="is"; TTT="tonight";
 
  elif (( hourNow >= 12 )) && (( hourNow <= 17 )); then 
    time_of_day="afternoon";HHH="are having"; GGG="is going"; TTT="later";

  elif (( hourNow >= 17 )) && (( hourNow <= 22 )); then 
    time_of_day="evening";  HHH="had"; 	GGG="has been"; TTT="";
fi
# this assumes no messages will be sent from 10 pm to 8:00 am

# Will be working on building a larger message database
ladies_start=( "Good $time_of_day" "Hey $name" "What's up $name," 
	"I've been thinking about you all $time_of_day," "Just wanted to tell you" 
	"I just texted to say" "Good $time_of_day love,")
ladies_end=( "I miss you." "I hope that you ${HHH} a great day." 
	"I hope that your day ${GGG} great." "you're really great, I hope you know that." 
	"I can't wait to see you." "you have a way of making me smile no matter what." "you're beautiful.")
family_start=( "Good $time_of_day" "Hey $name" "I've been meaning to call you" )
family_end=( "I hope all has been well at home." 
	"I will be home later next month love you." "let's talk sometime next week, are you free any time?" )
# male punctuation use tends to be more so grammerically inconsistent
mates_start=("Good day sir" "Hey" "What's up" "Yo")
mates_end=("what's going on $TTT" "what are you doing later?" 
	"are we going out tonight?" "how's everything been going.")
#################################################################

################# Build random message  #########################
messageCode=$target_group; 
# generate message beginning and ending
# wanted to simply state beginning=$[ $RANDOM % ${#random_group[@]} ];
# but I was unable to find an elegant solution to a bash-type 2D array

case $messageCode in  # case (group number) in all
	0) 
			begining=$[ $RANDOM % ${#ladies_start[@]} ];      
			endning=$[ $RANDOM % ${#ladies_end[@]} ];
			# assigns begining/ending index
			random_beginning=${ladies_start[$begining]};
			random_ending=${ladies_end[$endning]};
			# assigns begining/ending messages
			;;
	1) 
			begining=$[ $RANDOM % ${#family_start[@]} ];      
			endning=$[ $RANDOM % ${#family_end[@]} ];
			random_beginning=${family_start[$begining]};
			random_ending=${family_end[$endning]};
			;;
	2)
			begining=$[ $RANDOM % ${#mates_start[@]} ];      
			endning=$[ $RANDOM % ${#mates_end[@]} ];
			random_beginning=${mates_start[$begining]};
			random_ending=${mates_end[$endning]};
			;; 
     *)
			echo "Error!"
			echo "Make sure you really have ${number_of_groups} groups?"
			;;
esac

sentence="${random_beginning} ${random_ending}" 
#the space between beginning ^ and ending puts the space between the two 
# parts of the sentences this is by far the most important space to have ever existed. 

# this gets the current directory that the icon is located in                                                                                                  
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd):zen.png"
# this says take directory name dir replace all occurances of (//) with (/)                                                                                    
dir=${dir////:}
##################################################################                                                                                                                        

########## The Following Takes advantage of Apple's osascript ##########
#### This will work only if you are on a mac and logged into your iCloud account
osascript <<EOD                                                                                                                                                                           
 tell application "Finder"
        activate
                (display dialog "To: $name $number \n $sentence" ¬
                        with title "MSG" ¬
                        with icon file "$dir" ¬
                        buttons {"Send", "ReDo", "Nah"} ¬
                        default button 1)
 end tell
                if result = {button returned:"Send"} then
                        tell application "Messages"
                                send "$sentence" to buddy "$number" of (service 1 whose service type is iMessage)
                        end tell
                else if result = {button returned:"ReDo"} then
                        do shell script "./$scriptName ~"
                else
                        (display dialog "Message Canceled" ¬
                        with title "MSG" ¬
                        buttons {"OK"} ¬
                        giving up after 2)
                end if
EOD

# silences the exacution error that occurs when reDo is hit 
eval >&/dev/null

######################################################################
