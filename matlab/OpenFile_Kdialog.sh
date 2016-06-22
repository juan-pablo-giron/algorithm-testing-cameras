#!/bin/bash

###############################################################################
# This script opens a KDialog file browsing window that expects you to choose #
# a file to open starting in the current directory. Command substitution is   #
# used to save the path to the chosen file to a variable. The script then     #
# tests the exit status of the command.                                       
#
#                                                                             
#
# The kdialog command returns a 0 exit code if the Open button is pressed or  #
# if the Enter key is pressed when a file name has been selected or if a file #
# name is double-clicked. In that case, the script executes the actionyou    #
# assigned to the if section. In this example it displays a KDialog message   #
# box that displays the contents of the variable that contains your choice.   #
#                                                                             
#
# The kdialog command returns a 1 exit code if the Esc key or Cancel button   #
# is pressed. In that case, the script executes the action in you assigned to #
# the elif section. In this example it displays a KDialog sorry message.      
#
#                                                                             
#
# If anything else happens, the script executes the action you assigned to    #
# the else section. In this example it displays a KDialog error message.      
#
###############################################################################

variable=$(kdialog --getopenfilename .);

if [ "$?" = 0 ]; then
	kdialog --msgbox "$variable";
elif [ "$?" = 1 ]; then
	kdialog --sorry "YOU CHOSE CANCEL";
else
	kdialog --error "ERROR";
fi;
