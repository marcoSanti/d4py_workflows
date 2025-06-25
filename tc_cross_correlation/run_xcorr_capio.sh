#!/bin/bash

source /home/marco/Desktop/collab_rosa_f/d4py_env/bin/activate

cd /home/marco/Desktop/collab_rosa_f/d4py_workflows/tc_cross_correlation/

rm -rf /dev/shm/*
rm -rf /home/marco/Desktop/collab_rosa_f/d4py_workflows/tc_cross_correlation/capio_logs
#rm -rf /home/marco/Desktop/collab_rosa_f/d4py_workflows/tc_cross_correlation/OUTPUT

mkdir -p /home/marco/Desktop/collab_rosa_f/d4py_workflows/tc_cross_correlation/OUTPUT/DATA/
mkdir -p /home/marco/Desktop/collab_rosa_f/d4py_workflows/tc_cross_correlation/OUTPUT/XCORR/

export CAPIO_DIR=/home/marco/Desktop/collab_rosa_f/d4py_workflows/tc_cross_correlation/OUTPUT
export CAPIO_LOG_LEVEL=-1
export CAPIO_WORKFLOW_NAME=tc_cross_corr

export CAPIO_IGNORE_CHILD_THREADS=ON

/home/marco/Desktop/capio/cmake-build-release/src/server/capio_server -c ./capio-cross-corr.json &
CAPIO_SERVER_TREAD=$!


#LD_PRELOAD=/home/marco/Desktop/capio/cmake-build-debug/src/posix/libcapio_posix.so CAPIO_APP_NAME=prep \
#    dispel4py multi realtime_prep.py -f realtime_xcorr_input.jsn -n 10  


#LD_PRELOAD=/home/marco/Desktop/capio/cmake-build-release/src/posix/libcapio_posix.so CAPIO_APP_NAME=prep \
#    dispel4py simple realtime_prep.py -f realtime_xcorr_input.jsn 

PREP_PID=$!

#LD_PRELOAD=/home/marco/Desktop/capio/cmake-build-release/src/posix/libcapio_posix.so CAPIO_APP_NAME=xcorr \
   dispel4py simple realtime_xcorr.py



#wait $PREP_PID
kill $CAPIO_SERVER_TREAD
