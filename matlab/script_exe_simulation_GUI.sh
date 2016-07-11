#!/bin/sh

## Comments of the script


# ####### Creating the folder to the simulation #############
PATH_scriptMatlab=$PWD/

cd $PATH_scriptMatlab
cd ..
PATH_script=$PWD/
PATH_scriptPython=$PATH_script"python"/
cd ..


choice_TypeSim=$(kdialog --menu "CHOOSE ONE:" 1 "DVS" 2 "ATIS" --title "What is the camera that do you want simulate?")
echo $choice_TypeSim

############################################################
namefolder_netlistSpectre="Netlist_Spectre"
mkdir $namefolder_netlistSpectre
PATH_netlist_spectre=$PWD/$namefolder_netlistSpectre/

namefolder_simulation="Simulation_cameras"
mkdir $namefolder_simulation
PATH_simulation=$PWD/$namefolder_simulation/

namefolder_inputs="Inputs"
mkdir $namefolder_inputs
PATH_namefolder_Input=$PWD/$namefolder_inputs/

cd $PATH_simulation
############################################################

# ######### Reading user input ##########################

name_simulation=$(kdialog --inputbox "Write the name of the simulation");
if [ "$?" -ne 0 ]; then
  kdialog --error "Simulation Aborted"
  cd $PATH_scriptMatlab
  return
fi;

echo $PATH_simulation
mkdir $name_simulation
# Guarantee that the simulation has a unique name


while [ $? -ne 0 ]
do
    
  kdialog --yesno "The directory exist
   Do you want re-write it?";

  if [ "$?" = 0 ]
  then
    rm -fR $name_simulation
    mkdir $name_simulation
  elif [ "$?" = 1 ]; then
    name_simulation=$(kdialog --inputbox "Write other name different to the first");
    if [ "$?" = 0 ]
    then
      mkdir $name_simulation
    else
      return
    fi;
  else
    kdialog --error "Simulation Aborted";
    cd $PATH_scriptMatlab
    return
  fi;
  
done

cd $PATH_netlist_spectre

kdialog --msgbox "Select the netlist that you want simulate"

PATH_nameNetlist_spectre=$(kdialog --getopenfilename . "*.scs ");
if [ "$?" -ne 0 ]; then
  kdialog --error "Simulation Aborted"
  cd $PATH_scriptMatlab
  return
fi;
# extract the name of the netlist
nameNetlist_spectre=$(echo "$PATH_nameNetlist_spectre" | sed "s/.*\///")
nameNetlist_spectre_Orig=$nameNetlist_spectre
## Selecting the folder input
cd $PATH_namefolder_Input
count=1
a=""
direc=()
for i in $(ls -d */);
do
        a=$a$(echo "$count  ${i%%//} ")
        direc[$((count-1))]=${i%%//}
        count=$((count+1))
done
echo $a

choice=$(kdialog --menu "CHOOSE ONE:" $a --title "Select the folder of your input simulation")
echo $choice
echo ${direc[$((choice-1))]}
name_Signalsinput=${direc[$((choice-1))]}

if [ "$?" = 0 ]; then
  PATH_inputs=$PATH_namefolder_Input$name_Signalsinput
else
  kdialog --error "Simulation Aborted"
  cd $PATH_scriptMatlab
  return
fi;

echo "PATH_INPUTS $PATH_inputs"
cd $PATH_scriptMatlab


number_bits=$(kdialog --inputbox "Write the numbers of bits of your bus data");
if [ "$?" -ne 0 ]; then
  kdialog --error "Simulation Aborted"
  cd $PATH_scriptMatlab
  return
fi;

N=$(kdialog --inputbox "Write the columns of your camera");
if [ "$?" -ne 0 ]; then
  kdialog --error "Simulation Aborted"
  cd $PATH_scriptMatlab
  return
fi;

M=$(kdialog --inputbox "Write the numbers of rows of your camera");
if [ "$?" -ne 0 ]; then
  kdialog --error "Simulation Aborted"
  cd $PATH_scriptMatlab
  return
fi;

Vdoff=$(kdialog --inputbox "Write the Vdoff in format LONG");
if [ "$?" -ne 0 ]; then
  kdialog --error "Simulation Aborted"
  cd $PATH_scriptMatlab
  return
fi;

Vdon=$(kdialog --inputbox "Write the Vdon in format LONG");
if [ "$?" -ne 0 ]; then
  kdialog --error "Simulation Aborted"
  cd $PATH_scriptMatlab
  return
fi;

# For ATIS

if [ "$choice_TypeSim" = 2 ] 
then
  Vhigh=$(kdialog --inputbox "Write the Vhigh in format LONG");
  if [ "$?" -ne 0 ]; then
    kdialog --error "Simulation Aborted"
    cd $PATH_scriptMatlab
    return
  fi;
  Vlow=$(kdialog --inputbox "Write the Vlow in format LONG");
  if [ "$?" -ne 0 ]; then
    kdialog --error "Simulation Aborted"
    cd $PATH_scriptMatlab
    return
  fi;

fi


comment_simulation=$(kdialog --inputbox "Write some comments of your Simulation")
if [ "$?" -ne 0 ]; then
  comment_simulation="Sin comentarios"
fi;

############### CREATING THE DIRECTORIES   #########

PATH_folder_simulation=$PATH_simulation$name_simulation/

# Copy the original netlist to the folder Simulation
cp -f $PATH_nameNetlist_spectre $PATH_folder_simulation
cd $PATH_folder_simulation
cp -f $nameNetlist_spectre "netlist_"$name_simulation".scs"

# Write the comment simulation into the README_SIM.txt
echo "Original Netlist $nameNetlist_spectre" >> README_SIM.txt
echo "===========COMMENT ==========" >> README_SIM.txt
echo $comment_simulation >> README_SIM.txt

nameNetlist_spectre="netlist_"$name_simulation".scs"

name_folder_matlab_output="output_matlab"
name_matlab_output="output_matlab_"$name_simulation".csv"
name_images="images"

mkdir $name_folder_matlab_output
mkdir $name_images



PATH_sim_output_matlab=$PATH_folder_simulation$name_folder_matlab_output/
PATH_folder_input=$PATH_inputs/
PATH_folder_images=$PATH_folder_simulation$name_images/
name_folder_output_Spectre="netlist_"$name_simulation".raw"

# Is copied the input used in the simulation
#cd $nameinput
#cp -rf $PATH_namefolder_Input$name_Signalsinput/* $PATH_folder_input 
cd $PATH_folder_simulation

###################### EXPORTING THE PATHS ###############

export PATH_nameNetlist_spectre
export PATH_scriptMatlab
export PATH_script
export PATH_scriptPython
export PATH_netlist_spectre
export PATH_simulation
export PATH_folder_simulation
export PATH_sim_output_matlab
export PATH_folder_input
export PATH_folder_images
export name_simulation
export name_Signalsinput
export name_folder_matlab_output
export name_matlab_output
export name_images
export name_folder_output_Spectre
export number_bits
export M
export N
export Vdon
export Vdoff
export Vhigh
export Vlow
export nameNetlist_spectre_Orig
export nameNetlist_spectre

# Write one file name to export the same environment variables for future post processing

echo "#!/bin/bash" >> env_var.sh
echo "PATH_nameNetlist_spectre=$PATH_nameNetlist_spectre" >> env_var.sh
echo "PATH_scriptMatlab=$PATH_scriptMatlab" >> env_var.sh
echo "PATH_script=$PATH_script" >> env_var.sh
echo "PATH_scriptPython=$PATH_scriptPython" >> env_var.sh
echo "PATH_netlist_spectre=$PATH_netlist_spectre" >> env_var.sh
echo "PATH_simulation=$PATH_simulation" >> env_var.sh
echo "PATH_folder_simulation=$PATH_folder_simulation" >> env_var.sh
echo "PATH_sim_output_matlab=$PATH_sim_output_matlab" >> env_var.sh
echo "PATH_folder_input=$PATH_folder_input" >> env_var.sh
echo "PATH_folder_images=$PATH_folder_images" >> env_var.sh
echo "name_simulation=$name_simulation" >> env_var.sh
echo "name_Signalsinput=$name_Signalsinput" >> env_var.sh
echo "name_folder_matlab_output=$name_folder_matlab_output" >> env_var.sh 
echo "name_matlab_output=$name_matlab_output" >> env_var.sh
echo "name_images=$name_images" >> env_var.sh
echo "name_folder_output_Spectre=$name_folder_output_Spectre" >> env_var.sh
echo "number_bits=$number_bits" >> env_var.sh
echo "M=$M" >> env_var.sh
echo "N=$N" >> env_var.sh
echo "Vdoff=$Vdoff" >> env_var.sh
echo "Vdoff=$Vdon" >> env_var.sh
echo "Vhigh=$Vhigh" >> env_var.sh
echo "Vlow=$Vlow" >> env_var.sh
echo "nameNetlist_spectre_Orig=$nameNetlist_spectre_Orig" >> env_var.sh
echo "nameNetlist_spectre=$nameNetlist_spectre" >> env_var.sh
echo "export PATH_nameNetlist_spectre" >> env_var.sh
echo "export PATH_scriptMatlab" >> env_var.sh
echo "export PATH_script" >> env_var.sh
echo "export PATH_scriptPython" >> env_var.sh
echo "export PATH_netlist_spectre" >> env_var.sh
echo "export PATH_simulation" >> env_var.sh
echo "export PATH_folder_simulation" >> env_var.sh
echo "export PATH_sim_output_matlab" >> env_var.sh
echo "export PATH_folder_input" >> env_var.sh
echo "export PATH_folder_images" >> env_var.sh
echo "export PATH_folder_nohup" >> env_var.sh
echo "export name_simulation" >> env_var.sh
echo "export name_Signalsinput" >> env_var.sh
echo "export nameinput" >> env_var.sh
echo "export name_folder_matlab_output" >> env_var.sh 
echo "export name_matlab_output" >> env_var.sh
echo "export name_images" >> env_var.sh
echo "export name_folder_nohup" >> env_var.sh
echo "export name_matlab_out" >> env_var.sh
echo "export name_folder_output_Spectre" >> env_var.sh
echo "export number_bits" >> env_var.sh
echo "export M" >> env_var.sh
echo "export N" >> env_var.sh
echo "export Vdoff" >> env_var.sh
echo "export Vdon" >> env_var.sh
echo "export Vhigh" >> env_var.sh
echo "export Vlow" >> env_var.sh
echo "export nameNetlist_spectre_Orig" >> env_var.sh
echo "export nameNetlist_spectre" >> env_var.sh
#############################################################################################3


if [ "$choice_TypeSim" = 1 ]
then
  clear
  echo "Simulating a DVS camera wait it could take some minutes, hours or days"
  # Execution of commands for DVS

  cd $PATH_scriptPython

  python setting_input_netlist_UNIX_DVS2.py

  cd $PATH_folder_simulation

  spectre +mt ++aps -format psfascii $nameNetlist_spectre
  # Command for DVS pixel


  if [ "$?" = 0 ]
  then
    sleep 50
    cd $PATH_scriptPython
    python sort_data_DVS_pixel_UNIX.py
    
    if [ "$?" = 0 ]
    then
      #kdialog --msgbox "Starting the Post-processing with MATLAB close it when end"
      cd $PATH_scriptMatlab
      matlab -nodesktop -nosplash -r Model_CamDVS
      matlab -nodesktop -nosplash -r plotTran_DVS
    else
      kdialog --error "PLEASE verify your Python script there are some errors
      run post-processing after solved"
    fi
  else
    kdialog --error "PLEASE VERIFY IF YOUR ENVIROMENT VARIABLES FOR SPECTRE ARE CONFIGURED"
    cd $PATH_scriptMatlab
    return
  fi

else
  
  ## For the ATIS simulation is extracted the quantity of Frames
  #Col_Frame=$(cat $PATH_inputs/"README.txt" | awk '{print NF}' | sort -nu | tail -n 1)
  #Frames=$(cat $PATH_inputs/"README.txt" | grep "Frames" | cut -d " " -f $Col_Frame)
  #export Frames
  #echo "Frames=$Frames" >> env_var.sh
  #echo "export Frames" >> env_var.sh
  cd $PATH_scriptPython

  python setting_input_netlist_UNIX_ATIS.py

  spectre +mt ++aps -format psfascii $nameNetlist_spectre
  
fi

cd $PATH_scriptMatlab
