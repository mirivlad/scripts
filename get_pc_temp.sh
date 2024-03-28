#!/bin/bash
# This script show current GPU temperature for Radeon. 
# Require installed lm_sensors
GPUTEMP="$(sensors | grep -A 0 'edge' | cut -c15-22)"
CPUTEMP="$(sensors | grep -A 0 'Package id' | cut -c16-23)"
NVMETEMP="$(sensors | grep -A 0 'Composite' | cut -c15-23)"
echo "CPU:  $CPUTEMP";
echo "GPU:  $GPUTEMP";
echo "NVME: $NVMETEMP"
