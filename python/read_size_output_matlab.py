# Libraries

import os
import signal
import time

# get the environment variables
PID_SIM = os.environ['PID_SIM']
PID_PYTHON = os.environ['PID_PYTHON']
PATH_scriptMatlab = os.environ['PATH_scriptMatlab']
PATH_scriptPython = os.environ['PATH_scriptPython']
name_matlab_out = os.environ['name_matlab_out']


os.chdir(PATH_scriptMatlab)

size_max_meg = 1
size_max = size_max_meg*1024*1024; #convertion to bytes

_Notexit_ = 1
wait_file = 0
max_wait = 20
## Logic

while ( _Notexit_ ):

    if os.path.isfile(name_matlab_out):# Verify if exist one file
        size_file = os.path.getsize(name_matlab_out);
        if size_file >= size_max:
            os.kill(int(PID_SIM),signal.SIGKILL)
            _Notexit_ = False
            os.kill(int(PID_PYTHON),signal.SIGKILL)
            exit
        else:
            time.sleep(1)
            _Notexit_ = True
    else:

        if wait_file <= max_wait:
            time.sleep(1)
            wait_file = wait_file + 1
            _Notexit_ = True
        else:
            #os.chdir(PATH_scriptPython)
            #if os.path.isfile('nohup.out'):
            #    os.remove('nohup.out')
            #    os.kill(int(PID_PYTHON),signal.SIGKILL)
            #    exit
            #else:
            #    os.kill(int(PID_PYTHON),signal.SIGKILL)
            os.kill(int(PID_PYTHON),signal.SIGKILL) 
  	    exit
        
        

        
