#!/bin/bash
# This script show current CPU,GPU, and NVME temperature. 
# May be change for installed and showing by lm_sensors hardware 
# Require installed lm_sensors
GPUTEMP="$(sensors | grep -A 0 'edge' | cut -c15-22)"
CPUTEMP="$(sensors | grep -A 0 'Package id' | cut -c16-23)"
NVMETEMP="$(sensors | grep -A 0 'Composite' | cut -c15-23)"
echo "CPU:  $CPUTEMP";
echo "GPU:  $GPUTEMP";
echo "NVME: $NVMETEMP"
