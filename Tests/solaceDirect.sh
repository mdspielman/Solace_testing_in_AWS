#!/bin/bash

RUN_TIME_SEC=${1}
SOLACE_HOST=${2}
TEST_TYPE=${3}

. "./utils.bash"
. "./rateTableSolace.bash"


runSdkPerf ()
{
# Arguments are msgSize msgRate runSeconds 
let "msgNum=${2}*${3}"
let "msgRate=${2}/${STREAM_COUNT}"
generateTopicList ${STREAM_COUNT}
echo ""
echo ""
echo "${1} Byte size test - ${2} Msg/sec for ${3} seconds"
date +%F-%T
result=`taskset -c 1,2,3,4,5 ${SDKPERF} -cip=${SOLACE_HOST}\
 -ptl=${topicList} -stl=${topicList} -cc=${STREAM_COUNT} -mt=direct -nagle\
 -msa=${1} -mr=${msgRate} -mn=${msgNum} ${DEBUG} | grep -E '^Total|^Computed'`

sleep 1
}

for size in ${SIZES}
do
  runSdkPerf ${size} ${rate[${size}]} $RUN_TIME_SEC ${SOLACE_HOST}
  evaluateResults $msgNum ${rate[${size}]}  
done
date +%F-%T
