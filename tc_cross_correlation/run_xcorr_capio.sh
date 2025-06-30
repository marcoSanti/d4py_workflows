#!/bin/bash

source /home/marco/Desktop/collab_rosa_f/d4py_env/bin/activate

cd /home/marco/Desktop/collab_rosa_f/d4py_workflows/tc_cross_correlation/

rm -rf /dev/shm/*
rm -rf /home/marco/Desktop/collab_rosa_f/d4py_workflows/tc_cross_correlation/capio_logs
rm -rf /home/marco/Desktop/collab_rosa_f/d4py_workflows/tc_cross_correlation/OUTPUT

mkdir -p /home/marco/Desktop/collab_rosa_f/d4py_workflows/tc_cross_correlation/OUTPUT/DATA/
mkdir -p /home/marco/Desktop/collab_rosa_f/d4py_workflows/tc_cross_correlation/OUTPUT/XCORR/

export CAPIO_DIR=/home/marco/Desktop/collab_rosa_f/d4py_workflows/tc_cross_correlation/OUTPUT
export CAPIO_LOG_LEVEL=-1
export CAPIO_WORKFLOW_NAME=tc_cross_corr
export CAPIO_IGNORE_CHILD_THREADS=ON

CAPIO_BUILD_TARGET=debug
#CAPIO_BUILD_TARGET=release

MPI_PROC_CMD1=10
D4PY_CMD_1_PRE="mpiexec -np $MPI_PROC_CMD1"
D4PY_CMD_1="dispel4py mpi realtime_prep.py -f realtime_xcorr_input.jsn -n $MPI_PROC_CMD1"


MPI_PROC_CMD2=4
D4PY_CMD_2_PRE="mpiexec -np $MPI_PROC_CMD2"
D4PY_CMD_2="dispel4py mpi realtime_xcorr.py -n $MPI_PROC_CMD2"

#D4PY_CMD_2_PRE=""
#D4PY_CMD_2="dispel4py simple realtime_xcorr.py"

echo 
echo
echo "### CAPIO TESTS"
echo 
echo

servercmd=/home/marco/Desktop/capio/cmake-build-$CAPIO_BUILD_TARGET/src/server/capio_server 
$servercmd -c ./capio-cross-corr.json &

START_TIME_CAPIO=$(date +%s.%N)

$D4PY_CMD_1_PRE -x LD_PRELOAD=/home/marco/Desktop/capio/cmake-build-$CAPIO_BUILD_TARGET/src/posix/libcapio_posix.so -x CAPIO_APP_NAME=prep $D4PY_CMD_1 &
PREP_PID=$!

$D4PY_CMD_2_PRE -x LD_PRELOAD=/home/marco/Desktop/capio/cmake-build-$CAPIO_BUILD_TARGET/src/posix/libcapio_posix.so -x CAPIO_APP_NAME=xcorr $D4PY_CMD_2


END_TIME_CAPIO=$(date +%s.%N)
ELAPSED_CAPIO=$(echo "$END_TIME_CAPIO - $START_TIME_CAPIO" | bc)

wait $PREP_PID
killall capio_server



echo 
echo
echo "### NO CAPIO TESTS"
echo 
echo

rm -rf /dev/shm/*
rm -rf /home/marco/Desktop/collab_rosa_f/d4py_workflows/tc_cross_correlation/OUTPUT

mkdir -p /home/marco/Desktop/collab_rosa_f/d4py_workflows/tc_cross_correlation/OUTPUT/DATA/
mkdir -p /home/marco/Desktop/collab_rosa_f/d4py_workflows/tc_cross_correlation/OUTPUT/XCORR/


START_TIME_NO_CAPIO=$(date +%s.%N)
$D4PY_CMD_1_PRE $D4PY_CMD_1
$D4PY_CMD_2_PRE $D4PY_CMD_2
END_TIME_NO_CAPIO=$(date +%s.%N)
ELAPSED_NO_CAPIO=$(echo "$END_TIME_NO_CAPIO - $START_TIME_NO_CAPIO" | bc)


echo 
echo "CAPIO TEST ELAPSED TIME: ${ELAPSED_CAPIO} seconds"
echo "NO CAPIO TEST ELAPSED TIME: ${ELAPSED_NO_CAPIO} seconds"