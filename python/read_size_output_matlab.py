# Libraries

import os
import signal
import time

# get the environment variables
PID_SIM = os.environ['PID_SIM']
PATH_scriptMatlab = os.environ['PATH_scriptMatlab']
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
            exit
        else:
            time.sleep(1)
            _Notexit_ = True
    else:

        if wait_file <= max_wait:
            time.sleep(2)
            wait_file = wait_file + 1
            _Notexit_ = True
        else:
            exit
        
        

        
