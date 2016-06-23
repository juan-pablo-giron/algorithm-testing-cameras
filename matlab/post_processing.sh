#!/bin/bash


kdialog --msgbox "select the env_variables of the simulation 
 that you want doing post-processing"
PATH_env_var=$(kdialog --getopenfilename .  "env_var.sh ");
if [ "$?" -ne 0 ]; then
  kdialog --error "Post-processing Aborted"
  cd $PATH_scriptMatlab
  return
fi;

source PATH_env_var

