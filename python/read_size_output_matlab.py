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
size_file = s.path.getsize();

_Notexit_ = 1

## Logic

while ( _Notexit_ ):

    if os.path.isfile(fname):# Verify if exist one file
        size_file = s.path.getsize(name_matlab_out);
        if size_file >= size_max:
            os.kill(PID_SIM,signal.SIGKILL)
            _Notexit_ = False
            exit
        else:
            time.sleep(1)
            _Notexit_ = True
    else:
        _Notexit_ = False
        exit

        
