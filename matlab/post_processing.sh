#!/bin/bash

cd ../../
kdialog --msgbox "select the env_variables of the simulation 
 that you want doing post-processing"
PATH_env_var=$(kdialog --getopenfilename "env_var.sh"  "*.sh ");
if [ "$?" -ne 0 ]; then
  kdialog --error "Post-processing Aborted"
  return
fi;

source $PATH_env_var

#executing the commands for post-processing

cd $PATH_scriptPython
python sort_data_DVS_pixel_UNIX.py
  
if [ "$?" = 0 ]
then
  #kdialog --msgbox "Starting the Post-processing with MATLAB close it when end"
  cd $PATH_scriptMatlab
  echo $PATH_scriptMatlab
  matlab -nodesktop -nosplash -r plotTran_DVS
  matlab -nodesktop -nosplash -r Model_CamDVS
  kdialog --msgbox "Post-processing with successful check the images"
else
  kdialog --error "PLEASE verify your Python script there are some errors
  run post-processing after solved"
  kdialog --yesno "Do you want try to obtain the ideal behaviour?"
  if [ "$?" = 0 ]
  then
    cd $PATH_scriptMatlab
    matlab -nodesktop -nosplash -r Model_CamDVS
    kdialog --msgbox "Ideal Post-processing with successful"
  else
    return
  fi
fi
