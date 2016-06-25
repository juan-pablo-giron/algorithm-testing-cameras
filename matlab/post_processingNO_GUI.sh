#!/bin/bash

cd ../../

PATH_env_var=$(dialog --stdout --title "Choose an env_var file" --fselect $PWD/ 10 10)
if [ "$?" -ne 0 ]
then
  #log --error "Post-processing Aborted"
  return
fi

source $PATH_env_var

#executing the commands for post-processing

#cd $PATH_scriptPython
#python sort_data_DVS_pixel_UNIX.py
  
#if [ "$?" = 0 ]
#then
  #kdialog --msgbox "Starting the Post-processing with MATLAB close it when end"
cd $PATH_scriptMatlab
echo $PATH_scriptMatlab
matlab -nodesktop -nosplash -r plotTran_DVS
#  dialog --msgbox "Post-processing with successful check the images"
#else
#  kdialog --error "PLEASE verify your Python script there are some errors
#  run post-processing after solved"
#fi

